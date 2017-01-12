require 'bundler/setup'
require 'padrino-core/cli/rake'
require 'resque/tasks'

PadrinoTasks.use(:database)
PadrinoTasks.use(:sequel)
PadrinoTasks.init

task :default => :test
task 'resque:setup' => :environment
