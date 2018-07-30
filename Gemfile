source 'http://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"

end

# To avoid delete records
gem "paranoia", "~> 2.2"
# For bootstrap toggle buttons
gem "bootstrap-switch-rails"
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
gem 'will_paginate-bootstrap'
# Use momentjs and bootstrap3-datettimepicker for datetimepicker
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.47'
# Use chosen-rails for autocomplete on select
gem 'chosen-rails'
# Use simple_form for do forms more easily
gem 'simple_form'
# Use cocoon for nested forms
gem "cocoon"
# Use bootstrap-sass for views
gem 'bootstrap-sass'
# Use Pundit for permissions in classes
gem 'pundit'
# Use for make roles
gem 'rolify'
# Use rails_admin for admin side
gem 'rails_admin', '~> 1.3'
# Use devise as users' administrator
gem 'devise'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
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
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'listen'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  gem 'rails_layout'
  #Gem with better erros show de variables
  gem 'binding_of_caller'
  #Gem for view better errors
  gem 'better_errors'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

ruby "2.4.2"
