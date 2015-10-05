# == Schema Information
#
# Table name: blue_jeans_instances
#
#  id              :integer          not null, primary key
#  group_name      :string
#  group_region    :string
#  grant_type      :string
#  client_id       :string
#  client_secret   :string
#  enterprise_id   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  display_name    :string
#  support_emails  :string
#  deleted_at      :datetime
#  in_maintainance :boolean          default(FALSE), not null
#

class BlueJeansInstance < ActiveRecord::Base
  prepend ServiceInstance

  acts_as_paranoid

  validates :group_region, presence: true, if: lambda{ group_name.present? }
  validates :grant_type, presence: true
  validates :client_id, presence: true
  validates :client_secret, presence: true
  validates :enterprise_id, presence: true
  validates :support_emails, presence: true

  def title
    client_id
  end

  def token
    return @token if @token

    data = {
      client_id: client_id,
      client_secret: client_secret,
      grant_type: grant_type
    }.to_json

    response = JSON.parse RestClient::Request.execute(
      method:   'POST', 
      url:      'https://api.bluejeans.com/oauth2/token',
      payload:  data
    )

    response['access_token']
  end

  def register(username, first_name, last_name, email, company)
    data = {
      username: username,
      firstName: first_name,
      lastName: last_name,
      emailId: email,
      company: company
    }.to_json

    JSON.parse(RestClient::Request.execute(
      method:   'POST', 
      url:      "https://api.bluejeans.com/v1/enterprise/#{enterprise_id}/users?access_token=#{token}&billingCategory=ENTERPRISE",
      payload:  data,
      headers:  { content_type: :json }
    ))['id']
  end

  def create_default_settings(id)
    JSON.parse RestClient::Request.execute(
      method:   'POST', 
      url:      "https://api.bluejeans.com/v1/user/#{id}/room?access_token=#{token}",
      payload:  '{}',
      headers:  { content_type: :json }
    )
  end

  def unregister(id)
    RestClient::Request.execute(
      method: 'DELETE',
      url: "https://api.bluejeans.com/v1/enterprise/8858/users/#{id}/?access_token=#{token}"
    )
  end
end
