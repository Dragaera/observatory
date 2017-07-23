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

task 'ci:spec' => 'sq:migrate' do
  # The RSpec Rake task has the annoying (and non-overwritable) behaviour of
  # exiting early, ie on the first failed spec file.
  # As that's not desired on a CI server, we roll our own.
  exit system('rspec -fd -c spec/')
end
