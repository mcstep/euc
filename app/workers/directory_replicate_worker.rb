class DirectoryReplicateWorker
  include Sidekiq::Worker

  def perform(directory_id)
    Directory.unscoped.find(directory_id).replicate
  end
end