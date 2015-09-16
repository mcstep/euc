# == Schema Information
#
# Table name: salesforce_instances
#
#  id              :integer          not null, primary key
#  display_name    :string
#  group_name      :string
#  group_region    :string
#  username        :string
#  password        :string
#  security_token  :string
#  client_id       :string
#  client_secret   :string
#  time_zone       :string
#  common_locale   :string
#  language_locale :string
#  email_encoding  :string
#  profile_id      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#  host            :string
#

class SalesforceInstance < ActiveRecord::Base
  prepend ServiceInstance

  acts_as_paranoid

  validates :client_id, presence: true
  validates :client_secret, presence: true

  def title
    client_id
  end

  def client
    args = {
      api_version: "28.0",
      username: username,
      password: password,
      security_token: security_token,
      client_id: client_id,
      client_secret: client_secret
    }

    args[:host] = host if host.present?

    Restforce.new args
  end

  def register(username, first_name, last_name, email, real_email=email)
    client.create! 'User',
      email: real_email,
      'alias' => "#{username[0...5]}_#{rand(11...99)}",
      firstname: first_name,
      lastname: last_name,
      username: email,
      communitynickname: username,
      isactive: true,
      timezonesidkey: time_zone,
      localesidkey: common_locale,
      'EmailEncodingKey' => email_encoding,
      'LanguageLocaleKey' => language_locale,
      'ProfileId' => profile_id
  end

  def fetch_crm_data(crm_kind, id)
    if crm_kind == :salesforce_dealreg
      find_deal_registration id
    elsif crm_kind == :salesforce_opportunity
      find_opportunity id
    end
  end

  def find_deal_registration(id)
    client.get('/services/apexrest/v1.0/EucDemoRestService/EUC', objType: 'ORTN', recId: id).body.first
  end

  def find_opportunity(id)
    client.get('/services/apexrest/v1.0/EucDemoRestService/EUC', objType: 'Deal', recId: id).body.first
  end

  def update(id, settings)
    settings['Id'] = id
    client.update! 'User', settings
  end
end
