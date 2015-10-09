# == Schema Information
#
# Table name: directories
#
#  id           :integer          not null, primary key
#  host         :string
#  port         :string
#  api_key      :string
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  use_ssl      :boolean          default(FALSE), not null
#  stats_url    :string
#  display_name :string
#
# Indexes
#
#  index_directories_on_deleted_at  (deleted_at)
#

class Directory < ActiveRecord::Base
  prepend ServiceInstance

  acts_as_paranoid

  validates :host, presence: true

  def self.global_stats
    return @stats if @stats

    @stats = JSON.parse(
      RestClient.get(
        ENV['STATS_URL'] % {days: Date.today.yday}
      )
    )

    @stats.each do |e| 
      e['day']  = DateTime.parse(e['date']).to_date.to_s
    end

    @stats
  end

  def title
    url('')
  end

  def url(action)
    "http#{'s' if use_ssl}://#{host}:#{port || '80'}/#{action}"
  end

  def query(action, payload={}, params={})
    response = RestClient.post url(action), payload, params.merge(token: api_key)
    JSON.parse response rescue response
  end

  def authenticate(username, password, domain=nil)
    begin
      query 'authenticate', username: username, password: password, domain_suffix: domain
    rescue Exception => e
      return false
    end
  end

  def update_password(username, password=nil, domain=nil)
    if password.blank?
      query 'changePassword', username: username, domain_suffix: domain
    else
      query 'changeUserPassword', username: username, password: password, domain_suffix: domain
    end
  end

  def prolong(username, expires_at, domain=nil)
    query 'extendAccount', username: username, expires_at: expires_at.to_datetime.to_i*1000, domain_suffix: domain
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
    query "ad/replicate/#{entity}", {uname: 'demo.user'}, timeout: 500, open_timeout: 10
  end

  def create_profile(username, region, domain=nil)
    query 'createdir', username: username, region: region, domain_suffix: domain
  end

  def sync(entity)
    query "sync/#{entity}", uname: 'demo.user'
  end

  def office365_sync_all
    query "office365/sync/all"
  end

  def office365_sync(username, domain=nil)
    query "office365/sync", username: username, domain_suffix: domain
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
