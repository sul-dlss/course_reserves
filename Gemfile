source 'https://rubygems.org'

gem 'rails', '4.2.10'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'therubyracer'
gem 'nokogiri'

gem 'faraday'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
# >= 2.7.2 due to vulnerability
gem 'uglifier', '>= 2.7.2'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

gem 'jquery-rails'

gem 'whenever', "~> 0.9"

# Use honeybadger for exception reporting
gem 'honeybadger'

# to be run on machines w/ sqlite3
group :development, :test do
  gem "sqlite3"
end

group :development do
  gem "letter_opener"
end

group :test do
  gem 'poltergeist'
  gem 'capybara', ">= 2.2.0"
  gem 'rspec-rails', '~> 3.5', '>= 3.5.2'
  gem 'simplecov', :require => false
  gem 'database_cleaner'
end

# to be run on machines w/ mysql
group :production do
  gem "mysql2", '~> 0.3.20'
end

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'dlss-capistrano', '~> 3.0'
end

gem 'config'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
