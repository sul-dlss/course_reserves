source 'https://rubygems.org'

gem 'rails', '4.1.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'therubyracer'
gem 'nokogiri'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

gem 'jquery-rails'

gem 'whenever', "~> 0.9"

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
  gem 'squash_ruby', require: 'squash/ruby'
  gem 'squash_rails', require: 'squash/rails'
end

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'lyberteam-capistrano-devel', '~> 3.0'
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
