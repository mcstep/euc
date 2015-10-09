# == Schema Information
#
# Table name: deliveries
#
#  id           :integer          not null, primary key
#  profile_id   :integer
#  from_email   :string           not null
#  subject      :string           not null
#  body         :text             not null
#  send_at      :datetime
#  status       :integer          default(0), not null
#  response     :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  adhoc_emails :string
#

class Delivery < ActiveRecord::Base
  serialize :response

  as_enum :status, {queued: 0, sent: 1, error: 2}

  belongs_to :profile

  validates :subject, presence: true
  validates :body, presence: true
  validates :from_email, presence: true

  after_commit{ DeliveryRunWorker.perform_async(id) }

  def client
    @client ||= Mandrill::API.new ENV['MANDRILL_TOKEN']
  end

  def default_recipient
    [{name: 'EUC Demo Portal', email: 'eucdemohelp@vmware.com', type: 'to'}]
  end

  def recipients
    scope  = profile.present? ? profile.users : User.all
    emails = scope.map do |user|
      {email: user.email, name: user.display_name, type: 'bcc'}
    end

    adhoc_emails.split(',').each do |email|
      puts email.strip
      if email =~ /[a-zA-Z0-9._%]@(?:[a-zA-Z0-9]+\.)[a-zA-Z]{2,4}/
        emails << {email: email, type: 'bcc'}
      end
    end

    emails
  end

  def send!
    begin
      message = {
        from_email: from_email, html: body, to: recipients + default_recipient
      }
      self.response = client.messages.send(message, false, 'Main Pool', send_at)
      self.status = :sent
    rescue Mandrill::Error => e
      self.response = e.message
      self.status = :error
    end

    save!
  end
end
