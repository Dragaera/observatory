source 'https://rubygems.org'

# Optional JSON codec (faster performance)
# gem 'oj'

gem 'sentry-raven'

# Project requirements
gem 'rake'

# Component requirements
gem 'haml'
gem 'sequel'

# Test requirements

# Padrino Stable Gem
gem 'padrino', '0.14.4'

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
gem 'steam-condenser'

# Steam ID converter
gem 'steam-id2', '~> 0.4.4', require: 'steam_id'

# Bindings to Hive HTTP API
gem 'hive-stalker', '~>0.2.0', require: 'hive_stalker'
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
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'timecop'
end

group :development do
  gem 'pry'
  gem 'pry-byebug'
end
