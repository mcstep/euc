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
    Restforce.new api_version: "28.0",
      username: username,
      password: password,
      security_token: security_token,
      client_id: client_id,
      client_secret: client_secret
  end

  def register(username, first_name, last_name, email)
    client.create! 'User',
      email: email,
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

  def update(id, settings)
    settings['Id'] = id
    client.update! 'User', settings
  end
end
