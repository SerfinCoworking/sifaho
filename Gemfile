source 'http://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby "2.7.5"

# To translate routes
gem 'route_translator'
# To allow the use of model scopes into controllers
gem 'has_scope'
# To render svg images
gem 'inline_svg'
# To generate xlsx reports
gem 'axlsx_styler'
gem 'caxlsx'
gem 'caxlsx_rails'
# To give pretty colors to console
gem 'colorize', '~> 0.8.1'
# To call external apis
gem 'rest-client'
# To accept base 64
gem 'active_storage_base64'
# To icons
gem 'font_awesome5_rails'
gem 'jwt'
# To protect API from attacks
gem 'rack-attack'
# To make cross-origin AJAX requests
gem 'rack-cors'
# To serialize API
gem 'active_model_serializers'
# To resize images
gem 'mini_magick'
# To ldap athentication
gem 'devise_ldap_authenticatable'
# To generate reports
gem 'thinreports'
# To notifications
gem 'notifications'
# For cron jobs
gem 'whenever', require: false
# For pretty selects Silvio Moreto
gem 'bootstrap-select-rails'
# For full text search
gem 'pg_search'
# To avoid delete records
gem 'paranoia', '~> 2.2'
# For a lot of jquery functions
gem 'jquery-ui-rails'
# To group by date
gem 'groupdate'

gem 'active_median'
# Use chartkick and highcharts-rails to perform charts
gem 'chartkick'
gem 'highcharts-rails'
# Use filterrific to search, filter and sort lists
gem 'filterrific'
# Use will_paginate for limit the post per page
gem 'will_paginate', '~> 3.1.0'
gem 'will_paginate-bootstrap4'
# Use momentjs and bootstrap3-datettimepicker for datetimepicker
gem 'momentjs-rails', '>= 2.9.0'

gem 'bootstrap4-datetime-picker-rails'
# Use chosen-rails for autocomplete on select
gem 'chosen-rails'
# Use simple_form for do forms more easily
gem 'simple_form'
# Use cocoon for nested forms
gem 'cocoon'
# Use bootstrap 4.5 to layouts
gem 'bootstrap', '~> 4.5.0'
# Use Pundit for permissions in classes
gem 'pundit'
# Use for make roles
gem 'rolify'
# Use rails_admin for admin side
gem 'rails_admin', '~> 1.3'
# Use devise as users' administrator
gem 'devise'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem 'simple_command'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'rubocop-rails', require: false
  gem 'rubocop', require: false
  gem 'listen'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.36'
  gem 'selenium-webdriver', '~> 4.1.0'
  gem 'rspec-rails', '~> 5.0.2'
end

group :development do
  gem 'solargraph'
  gem 'rails_layout'
  # Gem with better erros show de variables
  gem 'binding_of_caller'
  # Gem for view better errors
  gem 'better_errors'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails', '~> 4.0'
  gem 'faker'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'rubocop-rspec', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
