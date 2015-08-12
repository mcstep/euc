# == Schema Information
#
# Table name: directories
#
#  id         :integer          not null, primary key
#  host       :string
#  port       :string
#  api_key    :string
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  use_ssl    :boolean          default(FALSE), not null
#
# Indexes
#
#  index_directories_on_deleted_at  (deleted_at)
#

class Directory < ActiveRecord::Base
  acts_as_paranoid

  validates :host, presence: true

  def title
    url('')
  end

  def url(action)
    "http#{'s' if use_ssl}://#{host}:#{port || '80'}/#{action}"
  end

  def query(action, payload, params={})
    response = RestClient.post url(action), payload, params.merge(token: api_key)
    JSON.parse response rescue response
  end

  def authenticate(username, password)
    begin
      query 'authenticate', username: username, password: password
    rescue Exception => e
      return false
    end
  end

  def update_password(username, password=nil)
    if password.blank?
      query 'changePassword', username: username
    else
      query 'changeUserPassword', username: username, password: password
    end
  end

  def prolong(username, expires_at)
    query 'extendAccount', username: username, expires_at: expires_at.to_datetime.to_i*1000
  end

  def signup(user_integration)
    expires_at = user_integration.directory_expiration_date.to_datetime.to_i*1000

    query 'signup',
      fname: user_integration.user.first_name,
      lname: user_integration.user.last_name,
      org: user_integration.user.company_name,
      username: user_integration.username,
      email: user_integration.user.email,
      title: user_integration.user.job_title,
      expires_at: expires_at,
      region: user_integration.user.home_region,
      domain_suffix: user_integration.integration.domain
  end

  def replicate(entity=nil)
    query "ad/replicate/#{entity}", {uname: 'demo.user'}, timeout: 200, open_timeout: 10
  end

  def create_profile(username, region, domain=nil)
    query 'createdir', username: username, region: region, domain_suffix: domain
  end

  def sync(entity)
    query "sync/#{entity}", uname: 'demo.user'
  end

  def office365_sync(username, domain=nil)
    query "/office365/sync/all", uname: username, domain_suffix: domain
  end

  def unregister(username, domain=nil)
    query 'unregister', username: username, domain_suffix: domain
  end

  def add_group(username, group, domain=nil)
    query 'addUserToGroup', username: username, group: group, domain_suffix: domain
  end

  def remove_group(username, group, domain=nil)
    query 'removeUserFromGroup', username: username, group: group, domain_suffix: domain
  end
end
