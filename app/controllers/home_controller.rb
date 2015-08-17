class HomeController < ApplicationController
  skip_after_action :verify_authorized
  helper StatsHelper
end
