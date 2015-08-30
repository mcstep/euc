class DirectoryReplicateWorker
  include Sidekiq::Worker

  def perform(directory_id)
    Directory.with_deleted.find(directory_id).replicate
  end
end