# == Schema Information
#
# Table name: user_requests
#
#  id       :integer          not null, primary key
#  ip       :string
#  date     :date
#  hour     :integer
#  quantity :integer
#
# Indexes
#
#  index_user_requests_on_date_and_hour  (date,hour)
#

class UserRequest < ActiveRecord::Base
end
