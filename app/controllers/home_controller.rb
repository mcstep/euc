class HomeController < ApplicationController
  def index
    @invitation = Invitation.new
  end
end
