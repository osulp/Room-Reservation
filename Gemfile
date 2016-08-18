source 'https://rubygems.org'

gem 'jquery-rails'
gem 'mysql2', '~> 0.3.18'
gem 'rails', '~> 5.0'

# Required to enable responds_to at controller level
gem 'responders'

gem 'simple_form'
gem 'yard'

# Draper for decoration
# v 3.0+ works with Rails5
gem 'draper', git: 'https://github.com/drapergem/draper'

# CAS Client
gem 'rubycas-client', git: 'https://github.com/osulp/rubycas-client.git'
gem 'rubycas-client-rails', git: 'https://github.com/osulp/rubycas-client-rails.git'

# New Relic
gem 'newrelic_rpm'

# Dalli for cache store
gem 'dalli'

# Unicorn for web server.
gem 'unicorn'

# Paranoia to simply hide deleted records
gem "paranoia", git: "https://github.com/rubysherpas/paranoia", branch: "rails5"

gem 'coffee-rails'
gem 'sass-rails'
gem 'uglifier'
gem 'execjs'
gem 'therubyracer'
gem 'jquery-ui-rails'
gem 'bootstrap-sass'
gem "compass-rails"

# Sidekiq for asynchronous jobs
gem 'sidekiq'
gem 'redis-namespace'

# Sidetiq for scheduling of jobs
gem 'sidetiq'

# CanCan for Permissions
gem 'cancan'

# Druthers for system settings
gem 'druthers'

# TinyMCE
gem 'tinymce-rails'

# PaperTrail for versioning
gem 'paper_trail'

# File uploading
gem 'carrierwave'

# Kaminari for pagination
gem 'kaminari'

# Let's try compression by google
gem 'closure-compiler'
gem 'yui-compressor'

gem 'rack-cors', :require => 'rack/cors'

group :development do
  gem 'meta_request'
  gem 'binding_of_caller'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'guard'
  gem 'guard-rspec'
  gem 'better_errors'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'pg'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'shoulda-matchers', :require => false
  gem 'timecop'
  gem 'capybara-screenshot'
  gem 'coveralls', require: false
end
