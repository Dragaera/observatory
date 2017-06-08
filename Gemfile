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
gem 'padrino', '0.14.1'

# Application server
gem 'unicorn'

gem 'pg'
gem 'sequel_pg', require: 'sequel'
gem 'sequel-pg-trgm'

# Background tasks
gem 'resque'
gem 'resque-scheduler'
gem 'resque-job-stats'

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
gem 'steam-id2', '~> 0.3.0', require: 'steam_id'

# Bindings to Hive HTTP API
gem 'hive-stalker', '~>0.1.0', require: 'hive_stalker'

gem 'dotenv'

group :test do
  gem 'rspec'
  gem 'capybara'
  gem 'rack-test', :require => 'rack/test'
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'timecop'
end

group :development do
  gem 'pry'
  gem 'pry-byebug'
end
