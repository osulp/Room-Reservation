source 'https://rubygems.org'

gem 'jquery-rails'
gem 'mysql2', '0.3.21'
gem 'rails'
gem 'simple_form'
gem 'yard'
gem 'sprockets', '~> 2.12'
#gem 'active_model_serializers', '~> 0.8.0'

# Draper for decoration
gem 'draper'

# CAS Client
gem 'rubycas-client', git: 'git://github.com/osulp/rubycas-client.git'
gem 'rubycas-client-rails', :git => 'git://github.com/osulp/rubycas-client-rails.git'

# Paranoia to simply hide deleted records
gem 'paranoia', '~> 2.0'

gem 'coffee-rails'
gem 'sass-rails', '~>4.0'
gem 'uglifier'
gem 'execjs'
gem 'jquery-ui-rails'
gem 'bootstrap-sass', '~>2.3.0'
gem "compass-rails"

gem 'puma'

# Sidekiq for asynchronous jobs
gem 'sidekiq'
# Sidetiq for scheduling of jobs
gem 'sidetiq'

# CanCan for Permissions
gem 'cancan'

# Druthers for system settings
gem 'druthers'

gem 'responders', '~> 2.0'

gem 'faraday'

# TinyMCE
gem 'tinymce-rails'

# PaperTrail for versioning
gem 'paper_trail', '~> 3.0.0'

# File uploading
gem 'carrierwave'

# Kaminari for pagination
gem 'kaminari'

# Let's try compression by google
gem 'closure-compiler'
gem 'yui-compressor'

gem 'rack-cors', :require => 'rack/cors'

# Displays a notification banner for development/staging environments.
#gem 'envb-rails'

gem 'capistrano', '~> 2.14'

gem 'active_model_serializers'
gem 'redis-namespace'

group :staging, :production do
  gem 'ddtrace'
end

group :development do
  #gem 'better_errors'
  #gem 'binding_of_caller'
  gem 'meta_request'
  gem 'binding_of_caller'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'guard'
  gem 'guard-rspec'
  gem 'better_errors'
end

group :development, :test do
  gem 'debase'
  gem 'debase-ruby_core_source'
  gem 'factory_bot'
  gem 'ruby-debug-ide'
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'shoulda-matchers', :require => false
  gem 'timecop'
  gem 'capybara-screenshot'
  gem 'coveralls', require: false
  gem 'rspec_junit_formatter'
end
