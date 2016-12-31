RACK_ENV = 'test' unless defined?(RACK_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
Dir[File.expand_path(File.dirname(__FILE__) + "/../app/helpers/**/*.rb")].each(&method(:require))

require 'capybara/rspec'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include FactoryGirl::Syntax::Methods

  conf.before(:suite) do
    FactoryGirl.find_definitions

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation

    conf.around(:each) do |spec|
      DatabaseCleaner.cleaning do
        spec.run
      end
    end
  end
end

def app(app = nil, &blk)
  @app ||= block_given? ? app.instance_eval(&blk) : app
  @app ||= Padrino.application
end
Capybara.app = app

