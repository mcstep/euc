class HomeController < ApplicationController
  before_action{ authorize :home }
  helper StatsHelper
end
