require 'bundler/setup'
require 'padrino-core/cli/rake'
require 'resque/tasks'
require 'resque/scheduler/tasks'

PadrinoTasks.use(:database)
PadrinoTasks.use(:sequel)
PadrinoTasks.init

task :default => :test
namespace :rescue do
  task setup: :environment

  task setup_schedule: :setup do
    Resque.schedule = YAML.load_file('config/schedule.yml')
  end
end
