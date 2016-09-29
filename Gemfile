source 'https://rubygems.org'

gem 'jquery-rails'
# gem 'mysql'
gem 'mysql2', '~> 0.3.20'
gem 'rails', :github => 'rails/rails', :branch => '4-2-stable'
# gem 'rails', '>= 5.0.0.rc2', '< 5.1'
gem 'simple_form'
gem 'yard'
gem 'active_model_serializers', '~> 0.8.0'

# Draper for decoration
gem 'draper'

# CAS Client
gem 'rubycas-client', git: 'git://github.com/terrellt/rubycas-client.git', branch: 'master'
gem 'rubycas-client-rails', :git => 'git://github.com/osulp/rubycas-client-rails.git'

# New Relic
gem 'newrelic_rpm'

# Dalli for cache store
gem 'dalli'

# Unicorn for web server.
gem 'unicorn'

# Cache digests for rails partials
# gem 'cache_digests'

# Paranoia to simply hide deleted records
gem 'paranoia', '~> 2.0'

gem 'coffee-rails'
gem 'sass-rails', '~>4.0'
gem 'uglifier'
gem 'execjs'
gem 'therubyracer'
# gem 'jquery-ui-rails'
gem 'jquery-ui-rails', '~>4.2'
gem 'bootstrap-sass', '~>2.3.0'
gem "compass-rails"
gem 'responders', '~> 2.0'

# Old Asset Precompile Behavior for Stylesheets
gem "sprockets-digest-assets-fix", :github => "tobiasr/sprockets-digest-assets-fix"

# Faye
gem 'faye'

# Thin for faye
gem 'thin'

# Sidekiq for asynchronous jobs
gem 'sidekiq'
# Sidetiq for scheduling of jobs
gem 'sidetiq'

# CanCan for Permissions
gem 'cancan'

# Druthers for system settings
gem 'druthers'

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
gem 'envb-rails'

gem 'redis-namespace'
group :development do
  #gem 'better_errors'
  #gem 'binding_of_caller'
  gem 'web-console', '~> 2.0'
  gem 'meta_request'
  gem 'binding_of_caller'
  gem 'spring'
  gem 'spring-commands-rspec'
  # gem 'guard'
  # gem 'guard-rspec'
  # gem 'better_errors'
  # gem 'debugger'
  gem 'debugger2', :git => "git://github.com/ko1/debugger2.git"
  gem 'pry'
  gem 'pry-byebug'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'pg'
  # gem 'jazz_hands', :github => "terrellt/jazz_hands"
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
