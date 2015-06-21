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
#
# Indexes
#
#  index_directories_on_deleted_at  (deleted_at)
#

class Directory < ActiveRecord::Base
  acts_as_paranoid

  validates :host, presence: true

  def url(action)
    "http://#{host}:#{port || '80'}/#{action}"
  end

  def query(action, payload, params={})
    response = RestClient.post url(action), payload, params.merge(token: api_key)
    raise Exception unless response.code == 200
    JSON.parse response
  end

  def authenticate(username, password)
    begin
      query 'authenticate', username: username, password: password
    rescue Exception => e
      return false
    end
  end

  def update_password(username, password)
    query 'changeUserPassword', username: username, password: password
  end

  def signup(user_integration)
    query 'signup',
      fname: user_integration.user.first_name,
      lname: user_integration.user.last_name,
      org: user_integration.user.company_name,
      username: user_integration.directory_username,
      email: user_integration.user.email,
      title: user_integration.user.job_title,
      expires_at: user_integration.directory_expiration_date,
      region: user_integration.user.home_region
  end

  def prolong(username, expires_at)
    query 'extendAccount', username: username, expires_at: expires_at.to_i*1000
  end

  def replicate
    query 'ad/replicate', {uname: 'demo.user'}, timeout: 200, open_timeout: 10
  end
end
