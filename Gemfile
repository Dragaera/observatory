source 'https://rubygems.org'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'

# Component requirements
gem 'haml'
gem 'sequel'

# Test requirements

# Padrino Stable Gem
gem 'padrino', '0.14.3'

gem 'sinatra-contrib', '>= 2.0.2'

# Application server
gem 'puma'

gem 'pg'
gem 'sequel_pg', require: 'sequel'
gem 'sequel-pg-trgm', ref: 'b9148f1a', git: 'https://github.com/mitchellhenke/sequel-pg-trgm'

# Background tasks
gem 'resque', '>= 1.27.4'
gem 'resque-scheduler', '>= 4.3.1'
gem 'resque-job-stats', '>= 0.4.2'

gem 'redis'

# BCrypt
gem 'bcrypt'

# Named timezones
gem 'tzinfo'

# Rate-limiting
gem 'ratelimit'

# Fancy charts
gem 'chartkick'

# Bindings to Steam Web-API
gem 'steam-condenser'

# Steam ID converter
gem 'steam-id2', '~> 0.4.4', require: 'steam_id'

# Bindings to Hive HTTP API
gem 'hive-stalker', '~>0.1.0', require: 'hive_stalker'
# Bindings to Gorge
gem 'gorgerb', '~> 0.1.0'

# Formatting helper
gem 'silverball', '~>0.1.0'

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
