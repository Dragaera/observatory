source 'https://rubygems.org'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'

# Component requirements
gem 'haml'
gem 'sqlite3'
gem 'sequel'

# Test requirements

# Padrino Stable Gem
gem 'padrino', '0.13.3.3'

# Application server
gem 'unicorn'

# No way to know which DB the user will use. And due to Docker-based 
# setups, there's no sensible way to have the user install those he needs.
gem 'mysql2'
gem 'pg'
gem 'sequel_pg', require: 'sequel'
gem 'sqlite3'

# Bindings to Steam Web-API
gem 'steam-condenser'

# Bindings to Hive HTTP API
gem 'hive-stalker', '~>0.1.0', require: 'hive_stalker'

gem 'dotenv'

group :test do
  gem 'rspec'
  gem 'capybara'
  gem 'rack-test', :require => 'rack/test'
  gem 'database_cleaner'
  gem 'factory_girl'
end
