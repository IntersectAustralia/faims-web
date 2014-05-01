source 'https://rubygems.org'

gem 'rails'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'haml'
gem 'haml-rails'
gem 'bootstrap-sass'
gem 'simple_form'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem 'therubyracer' # TODO should this be in group :assets ?
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'

  # cucumber gems
  gem 'cucumber'
  gem 'capybara'
  gem 'database_cleaner'
  #gem 'spork'
  gem 'launchy' # So you can do Then show me the page
  gem 'selenium-webdriver'
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'shoulda'
  gem 'spork'
  gem 'simplecov', '>=0.3.8', :require => false
  gem 'simplecov-rcov'
  gem 'email_spec'
end

gem 'unicorn'
gem 'delayed_job_active_record'
gem 'devise'
gem 'cancan'
gem 'nokogiri'
gem 'daemons'
gem 'webget_ruby_secure_random'
gem 'archive-tar-minitar'
gem 'rb-readline'

gem 'foreman'
gem 'god'
