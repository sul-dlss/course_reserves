source 'https://rubygems.org'

gem 'rails', '3.2.18'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'therubyracer'
gem 'nokogiri'

gem 'sass-rails',   '~> 3.2.3'
gem 'coffee-rails', '~> 3.2.1'

gem 'uglifier', '>= 1.0.3'

gem 'jquery-rails'

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
  gem 'rspec-rails'
  gem 'simplecov', :require => false
  gem 'database_cleaner'
end

# to be run on machines w/ mysql
group :production do
  gem "mysql"
end


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
