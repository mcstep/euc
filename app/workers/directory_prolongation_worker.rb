class DirectoryProlongationWorker
  include Sidekiq::Worker

  def perform(directory_prolongation_id)
    prolongation = DirectoryProlongation.unscoped.find(directory_prolongation_id)
    prolongation.user_integration.integration.directory.prolong(
      prolongation.user_integration.username,
      prolongation.expiration_date_new
    )
    GeneralMailer.directory_prolongation_email(prolongation).deliver_now
  end
end