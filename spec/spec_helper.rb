require 'rails_helper'
require 'vcr'
require 'sidekiq/testing'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'rack_session_access/capybara'

Sidekiq::Testing.fake!
WebMock.allow_net_connect!
Capybara.javascript_driver = :poltergeist

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
  c.default_cassette_options = { record: :new_episodes }
  c.configure_rspec_metadata!
  c.ignore_localhost = true
end

SimpleCov.start do
  add_filter '/spec/'
  at_exit { }

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Retrievers', 'app/retrievers'
  add_group 'Workers', 'app/workers'
  add_group 'Policies', 'app/policies'
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include ShowMeTheCookies, type: :feature

  config.before do
    Sidekiq::Worker.clear_all
  end

  config.after(:suite) do
    if SimpleCov.running
      silence_stream(STDOUT) do
        SimpleCov::Formatter::HTMLFormatter.new.format(SimpleCov.result)
      end

      SimpleCov::Formatter::SummaryFormatter.new.format(SimpleCov.result)
    end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run_excluding filter: true
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # config.profile_examples = 10

  config.order = :random
  Kernel.srand config.seed
end