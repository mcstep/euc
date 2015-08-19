# == Schema Information
#
# Table name: blue_jeans_instances
#
#  id            :integer          not null, primary key
#  group_name    :string
#  group_region  :string
#  grant_type    :string
#  client_id     :string
#  client_secret :string
#  enterprise_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class BlueJeansInstance < ActiveRecord::Base
  validates :group_region, presence: true, if: lambda{ group_name.present? }
  validates :grant_type, presence: true
  validates :client_id, presence: true
  validates :client_secret, presence: true
  validates :enterprise_id, presence: true

  def title
    client_id
  end

  def token
    return @token if @token

    @token = RestClient.post 'https://api.bluejeans.com/oauth2/token', {
      client_id: client_id,
      client_secret: client_secret,
      grant_type: grant_type
    }.to_json, {content_type: :json}
  end
end
