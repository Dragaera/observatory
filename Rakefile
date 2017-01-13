require 'bundler/setup'
require 'padrino-core/cli/rake'
require 'resque/tasks'
require 'resque/scheduler/tasks'

PadrinoTasks.use(:database)
PadrinoTasks.use(:sequel)
PadrinoTasks.init

task :default => :test

task 'resque:setup' => :environment
task 'resque:setup_schedule' => 'resque:setup' do
  schedule = YAML.load_file('config/schedule.yml')
  Resque.schedule = schedule
end
task 'resque:scheduler' => 'resque:setup_schedule'
