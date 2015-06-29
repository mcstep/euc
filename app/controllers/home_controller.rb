class HomeController < ApplicationController
  skip_after_action :verify_authorized

  def index
    @invitation = Invitation.from(current_user)
  end
end
