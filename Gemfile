source 'https://rubygems.org'

gem 'rails', '3.2.9'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3', '~> 1.3.7'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails', '~> 2.2.1'

gem 'jquery-ui-rails', '~> 4.0.2'

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

gem 'therubyracer', '~> 0.11.4' # TODO should this be in group :assets ?
group :development, :test do
  gem 'rspec-rails', '~> 2.13.0'
  gem 'factory_girl_rails', '~> 4.2.1'

  # cucumber gems
  gem 'cucumber', '~> 1.3.1'
  gem 'capybara', '~> 2.0.2'
  gem 'database_cleaner', '~> 0.9.1'
  #gem 'spork'
  gem 'launchy', '~> 2.3.0' # So you can do Then show me the page
end

group :test do
  gem 'cucumber-rails', '~> 1.3.1', require: false
  gem 'shoulda', '~> 3.4.0'
  gem 'spork', '~> 0.9.2'
end

gem 'unicorn', '~> 4.6.2'
gem 'delayed_job_active_record', '~> 0.4.4'
gem 'haml', '~> 4.0.2'
gem 'haml-rails', '~> 0.4'
gem 'bootstrap-sass', '~> 2.3.1'
gem 'simple_form', '~> 2.1.0'
gem 'devise', '~> 2.2.3'
gem 'email_spec', '~> 1.4.0', :group => :test
gem 'cancan', '~> 1.6.9'
gem 'nokogiri', '= 1.5.5'
gem 'daemons', '~> 1.1.9'
gem 'webget_ruby_secure_random', '~> 1.2.1'
gem 'archive-tar-minitar', '~> 0.5.2'
gem 'foreman', '~> 0.63.0'