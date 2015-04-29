class FeaturesController < ApplicationController
  before_action :set_feature, only: [:update]
  before_action :require_login
  before_action :require_admin

  def index
  end

  def update
    respond_to do |format|
      if @feature.update(feature_params)
        Feature.refresh!
        format.html { render :index, notice: 'Invitation was successfully updated.' }
        format.json { render :index, status: :ok }
      else
        format.html { render :index }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  def flush
    Feature.refresh!
    head :no_content
  end

  private
    def set_feature
      @feature = FeatureToggle.find(params[:id])
    end

    def require_login
      redirect_to log_in_path, notice: "Please sign in" unless current_user
    end

    def require_admin
      unless current_user && current_user.admin?
        redirect_to dashboard_path, :alert => "Access denied."
      end
    end

    def feature_params
      params.require(:feature).permit(:active)
    end
end
