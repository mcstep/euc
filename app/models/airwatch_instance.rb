# == Schema Information
#
# Table name: airwatch_instances
#
#  id              :integer          not null, primary key
#  group_name      :string
#  group_region    :string
#  api_key         :string
#  host            :string
#  user            :string
#  password        :string
#  parent_group_id :string
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_airwatch_instances_on_deleted_at  (deleted_at)
#

class AirwatchInstance < ActiveRecord::Base
  acts_as_paranoid

  validates :host,            presence: true
  validates :user,            presence: true
  validates :password,        presence: true
  validates :parent_group_id, presence: true
  validates :group_name,      presence: true
  validates :group_region,    presence: true

  def query(action, payload=nil, method: :post)
    response = RestClient::Request.execute(
      method:   method, 
      url:      "https://#{host}/API/v1/#{action}",
      user:     user,
      password: password,
      payload:  (payload.to_json if payload),
      headers:  { host: host, 'aw-tenant-code' => api_key, content_type: :json, accept: :json }
    )
    JSON.parse(response) if response != "null"
  end

  def add_group(name)
    query "system/groups/#{parent_group_id}/creategroup",
      'Name'               => name,
      'GroupId'            => name,
      'LocationGroupType'  => 'Prospect',
      'AddDefaultLocation' => 'Yes'
  end

  def delete_group(id)
    query "system/groups/#{id}/delete", method: :delete
  end

  def add_user(username)
    query "system/users/adduser",
      'UserName' => username,
      'Status' => "true",
      'SecurityType' => "Directory",
      'Role' => "VMWDemo"
  end

  def activate(id)
    begin
      query "system/users/#{id}/activate"
    rescue RestClient::BadRequest => e
      raise e unless e.response =~ /User not found or does not have access to retrieve the details/
    end
  end

  def deactivate(id)
    begin
      query "system/users/#{id}/deactivate"
    rescue RestClient::BadRequest => e
      raise e unless e.response =~ /User not found or does not have access to retrieve the details/
    end
  end

  def delete_user(id)
    begin
      query "system/users/#{id}/delete", method: :delete
    rescue RestClient::BadRequest => e
      raise e unless e.response =~ /User not found or does not have access to delete the user/
    end
  end
end
