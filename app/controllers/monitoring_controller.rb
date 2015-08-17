class MonitoringController < ApplicationController
  skip_before_action :require_login
  skip_after_action :verify_authorized

  before_action do
    if !ENV['MONITORING_SECRET'].present? || params['secret'] != ENV['MONITORING_SECRET']
      render status: 404, text: ''
    end
  end

  def sidekiq
    render json: Sidekiq::Stats::Queues.new.lengths
  end
end
