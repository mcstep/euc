# == Schema Information
#
# Table name: box_instances
#
#  id                  :integer          not null, primary key
#  display_name        :string
#  group_name          :string
#  group_region        :string
#  token_retriever_url :string
#  username            :string
#  password            :string
#  client_id           :string
#  client_secret       :string
#  access_token        :string
#  refresh_token       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class BoxInstance < ActiveRecord::Base
  prepend ServiceInstance

  after_commit{ BoxInstanceFetcherWorker.perform_async(id) }

  def title
    username
  end

  def register(login, name)
    response = RestClient::Request.execute(
      method:   'POST', 
      url:      'https://api.box.com/2.0/users',
      payload:  {login: login, name: name}.to_json,
      headers:  { content_type: :json, 'Authorization' => "Bearer #{access_token}" }
    )
    JSON.parse(response) if response.present? && response != "null"
  end

  def unregister(id)
    RestClient::Request.execute(
      method:   'DELETE',
      url:      "https://api.box.com/2.0/users/#{id}",
      headers:  { content_type: :json, 'Authorization' => "Bearer #{access_token}" }
    )
  end
end
