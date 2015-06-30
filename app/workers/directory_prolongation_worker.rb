class DirectoryProlongationWorker
  include Sidekiq::Worker

  def perform(directory_prolongation_id)
    prolongation = DirectoryProlongation.unscoped.find(directory_prolongation_id)
    GeneralMailer.directory_prolongation_email(prolongation).deliver
  end
end