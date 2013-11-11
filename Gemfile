source 'https://rubygems.org'


gem 'jquery-rails'
gem 'mysql2'
gem 'pg'
gem 'rails', '~> 4.0.0'
gem 'simple_form'
gem 'yard'
gem 'active_model_serializers', '~> 0.8.0'

# Draper for decoration
gem 'draper'

# CAS Client
gem 'rubycas-client', git: 'git://github.com/terrellt/rubycas-client.git', branch: 'master'
gem 'rubycas-client-rails', :git => 'git://github.com/rubycas/rubycas-client-rails.git'

# New Relic
gem 'newrelic_rpm'

# Dalli for cache store
gem 'dalli'

# Unicorn for web server.
gem 'unicorn'

# Cache digests for rails partials
gem 'cache_digests'

# Paranoia to simply hide deleted records
gem 'paranoia', '~> 2.0'

gem 'coffee-rails'
gem 'sass-rails'
gem 'uglifier'
gem 'execjs'
gem 'therubyracer'
gem 'jquery-ui-rails'
gem 'bootstrap-sass'
gem "compass-rails", "~> 2.0.alpha.0"

# Old Asset Precompile Behavior for Stylesheets
gem "sprockets-digest-assets-fix"

# Faye
gem 'faye'

# Thin for faye
gem 'thin'

# Sidekiq for asynchronous jobs
gem 'sidekiq'

# CanCan for Permissions
gem 'cancan'

# Druthers for system settings
gem 'druthers'

group :development do
  #gem 'better_errors'
  #gem 'binding_of_caller'
  gem 'jazz_hands'
  gem 'meta_request'
  gem 'binding_of_caller'
  gem 'spring'
  gem 'guard'
  gem 'guard-rspec'
  gem 'better_errors'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'capybara-screenshot'
  gem 'coveralls', require: false
end
