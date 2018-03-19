RACK_ENV = 'test' unless defined?(RACK_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
Dir[File.expand_path(File.dirname(__FILE__) + "/../app/helpers/**/*.rb")].each(&method(:require))

require 'capybara/rspec'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include FactoryBot::Syntax::Methods

  # conf.filter_run_including focus: true

  conf.before(:suite) do
    FactoryBot.find_definitions

    DatabaseCleaner.strategy = :transaction
    # This will also delete FrequencyUpdate entities - which are used in the
    # Player model.
    # DatabaseCleaner.clean_with :truncation

    conf.around(:each) do |spec|
      DatabaseCleaner.cleaning do
        spec.run
      end
    end
  end

  conf.profile_examples = 10
end

def app(app = nil, &blk)
  @app ||= block_given? ? app.instance_eval(&blk) : app
  @app ||= Padrino.application
end
Capybara.app = app

