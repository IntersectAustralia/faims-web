source 'https://rubygems.org'

gem 'rails', '~> 3.2.19'
gem 'sqlite3'

# Gems used only for assets and not required
# in production environments by default.
gem 'therubyracer' # TODO should this be in group :assets ?
gem 'sass-rails'
group :assets do
  gem 'coffee-rails'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'haml'
gem 'haml-rails'
gem 'bootstrap-sass', '~> 2.3.2.2'
gem 'simple_form'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'

  # cucumber gems
  gem 'cucumber'
  gem 'capybara'
  gem 'database_cleaner'
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
gem 'devise', '~> 2.2.8'
gem 'cancan', '= 1.6.9'
gem 'nokogiri'
gem 'daemons'
gem 'rb-readline'
gem 'foreman'
gem 'god'
gem 'redcarpet'
gem 'highline'
gem 'antlr3'