# == Schema Information
#
# Table name: user_authentications
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  ip         :string
#  successful :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_authentications_on_created_at  (created_at)
#

class UserAuthentication < ActiveRecord::Base
  include StatsProvider

  belongs_to :user

  scope :recent, lambda{ where("created_at > ?", Date.today - 30) }
end
