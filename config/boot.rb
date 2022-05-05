# Defines our constants
RACK_ENV = ENV['RACK_ENV'] ||= 'development' unless defined?(RACK_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'bundler/setup'
Bundler.require(:default, RACK_ENV)

Padrino::Logger::Config[:production][:log_level] = :debug
Padrino::Logger::Config[:production][:stream] = :stdout
##
# ## Enable devel logging
#
# Padrino::Logger::Config[:development][:log_level]  = :devel
# Padrino::Logger::Config[:development][:log_static] = true
#
# ## Configure Ruby to allow requiring features from your lib folder
#
# $LOAD_PATH.unshift Padrino.root('lib')
#
# ## Enable logging of source location
#
# Padrino::Logger::Config[:development][:source_location] = true
#
# ## Configure your I18n
#
# I18n.default_locale = :en
# I18n.enforce_available_locales = false
#
# ## Configure your HTML5 data helpers
#
# Padrino::Helpers::TagHelpers::DATA_ATTRIBUTES.push(:dialog)
# text_field :foo, :dialog => true
# Generates: <input type="text" data-dialog="true" name="foo" />
#
# ## Add helpers to mailer
#
# Mail::Message.class_eval do
#   include Padrino::Helpers::NumberHelpers
#   include Padrino::Helpers::TranslationHelpers
# end

##
# Require initializers before all other dependencies.
# Dependencies from 'config' folder are NOT re-required on reload.
#
Padrino.dependency_paths.unshift Padrino.root('config/initializers/*.rb')

##
# Add your before (RE)load hooks here
# These hooks are run before any dependencies are required.
#
Padrino.before_load do
  unless RACK_ENV == 'production'
    config_files = [
      File.expand_path("../../.env.#{ Padrino.env }", __FILE__),
      File.expand_path('../../.env', __FILE__),
    ]
    puts "Loading config files: #{ config_files.inspect }"
    Dotenv.load(*config_files)
  end

  require_relative 'observatory'

  Resque.redis = "#{ Observatory::Config::Redis::HOST }:#{ Observatory::Config::Redis::PORT }"
  schedule = YAML.load_file('config/schedule.yml')
  Resque.schedule = schedule
end

##
# Add your after (RE)load hooks here
#
Padrino.after_load do
  if Observatory::Config::Steam::WEB_API_KEY
    SteamCondenser::Community::WebApi.api_key = Observatory::Config::Steam::WEB_API_KEY
  end

  if Observatory::Config::Sentry.enabled?
    puts 'Enabling sentry integration.'

    Sentry.init do |config|
      config.dsn = Observatory::Config::Sentry::DSN
      config.release = Observatory::VERSION
      config.send_default_pii = true
    end

    Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Sentry]
    Resque::Failure.backend = Resque::Failure::Multiple
  else
    puts 'Skipping sentry integration.'
  end

    REDIS = Redis.new(
      host: Observatory::Config::Redis::HOST,
      port: Observatory::Config::Redis::PORT,
    )
end

Padrino.load!
