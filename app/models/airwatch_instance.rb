# == Schema Information
#
# Table name: airwatch_instances
#
#  id                :integer          not null, primary key
#  group_name        :string
#  group_region      :string
#  api_key           :string
#  host              :string
#  user              :string
#  password          :string
#  parent_group_id   :string
#  admin_roles       :text
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  security_pin      :string
#  display_name      :string
#  templates_api_url :string
#  templates_token   :string
#  use_templates     :boolean          default(FALSE), not null
#  use_admin         :boolean          default(FALSE), not null
#  use_groups        :boolean          default(TRUE), not null
#
# Indexes
#
#  index_airwatch_instances_on_deleted_at  (deleted_at)
#

class AirwatchInstance < ActiveRecord::Base
  prepend ServiceInstance

  acts_as_paranoid

  serialize :admin_roles

  validates :host,            presence: true
  validates :user,            presence: true
  validates :password,        presence: true
  validates :parent_group_id, presence: true
  validates :group_region,    presence: true, if: lambda{ group_name.present? }
  validates :security_pin,    presence: true

  def title
    host
  end

  def admin_roles_text
    return '' if admin_roles.blank?

    admin_roles.map{|x| "#{x['Id']},#{x['LocationGroupId']}"}.join("\n")
  end

  def admin_roles_text=(value)
    self.admin_roles = []

    value.strip.split("\n").each do |row|
      row = row.strip.split(',')
      self.admin_roles << {'Id' => row[0], 'LocationGroupId' => row[1]}
    end
  end

  def effective_admin_roles(user_integration)
    return admin_roles unless use_templates

    roles  = []
    groups = AirwatchTemplate.produce(user_integration).to_h

    admin_roles.each do |entry|
      roles << {'Id' => entry['Id'], 'LocationGroupId' => groups[entry['LocationGroupId']].to_s}
    end

    roles
  end

  def query(action, payload=nil, method: :post)
    response = RestClient::Request.execute(
      method:   method, 
      url:      "https://#{host}/API/v1/#{action}",
      user:     user,
      password: password,
      payload:  (payload.to_json if payload),
      headers:  { host: host, 'aw-tenant-code' => api_key, content_type: :json, accept: :json }
    )
    JSON.parse(response) if !response.blank? and response != "null"
  end

  def add_group(name)
    query "system/groups/#{parent_group_id}/creategroup",
      'Name'               => name,
      'GroupId'            => name,
      'LocationGroupType'  => 'Prospect',
      'AddDefaultLocation' => 'Yes'
  end

  def delete_group(id)
    query "system/groups/#{id}/delete", {'SecurityPIN' => security_pin}, method: :delete
  end

  def add_user(username)
    query 'system/users/adduser',
      'UserName' => username,
      'Status' => 'true',
      'SecurityType' => 'Directory',
      'LocationGroupId' => parent_group_id,
      'Role' => 'VMWDemo'
  end

  def add_admin_user(user_integration)
    query "system/admins/addadminuser",
      'UserName' => user_integration.username, 
      'LocationGroupId' => parent_group_id,
      'IsActiveDirectoryUser' => 'true',
      'RequiresPasswordChange' => 'false',
      'Roles' => effective_admin_roles(user_integration)
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

  def delete_admin_user(id)
    begin
      query "system/admins/#{id}/delete", method: :delete
    rescue RestClient::BadRequest => e
      raise e unless e.response =~ /User not found or does not have access to retrieve the details/
    end
  end

  def generate_template(domain, company)
    url = URI(templates_api_url)
    url.query = "token=#{Rack::Utils.escape templates_token}"

    begin
      RestClient::Request.execute(
        method:   'POST',
        url:      url.to_s,
        payload:  { domainName: domain, partnerName: "#{company} (#{domain})" }.to_json,
        headers:  { content_type: :json, accept: :json }
      )
    rescue RestClient::Conflict => e
    end

    url.path += '/' unless url.path.ends_with?('/')
    url.path += domain
    url.normalize!

    JSON.parse(RestClient.get url.to_s)
  end
end
