# == Schema Information
#
# Table name: user_requests
#
#  id       :integer          not null, primary key
#  ip       :string
#  date     :date
#  hour     :integer
#  quantity :integer
#  country  :string
#
# Indexes
#
#  index_user_requests_on_date_and_hour  (date,hour)
#

class UserRequest < ActiveRecord::Base
  before_create :assign_country

  scope :recent, lambda{ where("date > ?", Date.today - 30) }

  def assign_country
    self.country = GeoIP.new(Rails.root.join 'db/geo.dat').country(ip).country_code2
  end
end
