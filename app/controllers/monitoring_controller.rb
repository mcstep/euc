class MonitoringController < ApplicationController
  skip_before_action :require_login
  skip_after_action :verify_authorized

  def sidekiq
    render json: Sidekiq::Stats::Queues.new.lengths
  end
end
