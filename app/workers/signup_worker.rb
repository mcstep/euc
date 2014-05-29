class SignupWorker
  include Sidekiq::Worker

  def perform(name, count)
    puts 'Doing hard work - works on HEROKU!'
  end
end
