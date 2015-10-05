# == Schema Information
#
# Table name: google_apps_instances
#
#  id               :integer          not null, primary key
#  group_name       :string
#  group_region     :string
#  key_base64       :text
#  key_password     :string
#  initial_password :string
#  service_account  :string
#  act_on_behalf    :string
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  display_name     :string
#  in_maintainance  :boolean          default(FALSE), not null
#
# Indexes
#
#  index_google_apps_instances_on_deleted_at  (deleted_at)
#

class GoogleAppsInstance < ActiveRecord::Base
  acts_as_paranoid

  after_validation{ errors.add(:key_file, :blank) if errors[:key_base64].any? }

  validates :key_base64, presence: true
  validates :initial_password, presence: true
  validates :service_account, presence: true
  validates :act_on_behalf, presence: true
  validates :group_region, presence: true, if: lambda{ group_name.present? }

  def title
    act_on_behalf
  end

  def key=(value)
    self.key_base64 = Base64.encode64(value)
  end

  def key
    Base64.decode64(key_base64) if key_base64.present?
  end

  def key_file
    file = Tempfile.new('google_apps_key')
    file.binmode
    file.write(key)
    file.rewind
    file.path
  end

  def key_file=(value)
    self.key_base64 = Base64.encode64(value.read)
  end

  def client
    return @client if @client

    @client = Google::APIClient.new(
      application_name: 'EUC VMWare Portal',
      application_version: '1.0.0'
    )

    # Load our credentials for the service account
    key      = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_password)
    asserter = Google::APIClient::JWTAsserter.new(service_account, 'https://www.googleapis.com/auth/admin.directory.user', key)

    @client.authorization = asserter.authorize(act_on_behalf)
    @client.authorization.fetch_access_token!

    @client
  end

  def execute(*args)
    result = client.execute(*args)

    Faraday::Response::RaiseError.new.on_complete(result.response.env)
    result
  end

  def register(email, first_name, last_name)
    directory = client.discovered_api('admin', 'directory_v1')

    begin
      execute(
        api_method: directory.users.insert,
        body_object: directory.users.insert.request_schema.new(
          name: { familyName: last_name, givenName: first_name },
          primaryEmail: email,
          password: initial_password
        )
      )
    rescue Faraday::ClientError => e
      body = JSON.parse(e.response[:body])

      return if e.response[:status] == 409 && \
        body['error']['errors'][0]['reason'] == 'duplicate' && \
        body['error']['errors'].length == 1

      raise e
    end
  end

  def unregister(email)
    directory = client.discovered_api('admin', 'directory_v1')

    execute(
      api_method: directory.users.delete,
      event: 'add',
      parameters: {'userKey' => email}
    )
  end

  def search(user_integration, email=user_integration.email, domain=user_integration.integration.domain)
    directory = client.discovered_api('admin', 'directory_v1')

    JSON.parse execute(
      api_method: directory.users.list,
      parameters: {
        'domain' => domain,
        'query'  => "email:#{email}*"
      }
    ).body
  end

  def registered?(*args)
    search(*args)['users'].present?
  end
end
