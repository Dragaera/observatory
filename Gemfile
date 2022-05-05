source 'https://rubygems.org'

# Optional JSON codec (faster performance)
# gem 'oj'

gem 'sentry-ruby'
gem 'sentry-resque'

# Project requirements
gem 'rake'

# Component requirements
gem 'haml'
gem 'sequel'

# Test requirements

# Padrino Stable Gem
gem 'padrino', '0.15.1'

gem 'sinatra-contrib'

# Application server
gem 'puma'

gem 'pg'
gem 'sequel_pg', require: 'sequel'
gem 'sequel-pg-trgm'

# Background tasks
gem 'resque', require: ['resque', 'resque/failure/multiple', 'resque/failure/redis']
gem 'resque-scheduler'
gem 'resque-job-stats'
gem 'resque-sentry'

gem 'redis'

# BCrypt
gem 'bcrypt'

# Named timezones
gem 'tzinfo'

# Rate-limiting
gem 'ratelimit'

# Fancy charts
gem 'chartkick', '>= 3.0.2'

# Bindings to Steam Web-API
# The most recent published version (1.3.11) does not yet contain fixes for
# Ruby 2.7+ compatiblity, so we'll need to rely on Github.
gem 'steam-condenser', git: 'https://github.com/koraktor/steam-condenser-ruby.git', ref: '3ee580b'

# Steam ID converter
# We also need a version of it which is compatible with the unpublished version
# of `steam-condenser` we use. Fun. :)
gem 'steam-id2', git: 'https://github.com/Dragaera/steam-id.git', ref: 'dc106b7' , require: 'steam_id'

# Bindings to Hive HTTP API
gem 'hive-stalker', '~>0.3.1', require: 'hive_stalker'
# Bindings to Gorge
gem 'gorgerb', '~> 0.2.0'

# Formatting helper
gem 'silverball', '~>0.1.3'

group :development, :test do
  gem 'dotenv'
end

group :test do
  gem 'capybara'
  gem 'rspec'
  gem 'rack-test', :require => 'rack/test'
  gem 'database_cleaner-sequel'
  gem 'factory_bot'
  gem 'timecop'
end

group :development do
  gem 'pry'
  gem 'pry-byebug'
end
