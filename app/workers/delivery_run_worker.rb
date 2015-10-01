class DeliveryRunWorker
  include Sidekiq::Worker

  def perform(delivery)
    delivery = Delivery.find(delivery) unless delivery.is_a?(Delivery)

    return if delivery.sent?
    delivery.send!
  end
end