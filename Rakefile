require 'bundler/setup'
require 'padrino-core/cli/rake'
require 'resque/tasks'
require 'resque/scheduler/tasks'

PadrinoTasks.use(:database)
PadrinoTasks.use(:sequel)
PadrinoTasks.init

task :default => :test

task 'resque:setup' => :environment
task 'resque:scheduler' => 'resque:setup'

task 'ci:spec' => ['sq:migrate', :spec]
