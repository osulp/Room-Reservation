require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
#require "active_resource/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

Bundler.require(:default, Rails.env)
module RoomReservation
  class Application < Rails::Application
    application_config = YAML.load_file('config/config.yml')|| {}
    config.active_record.default_timezone = :utc

    config.generators do |generate|
      generate.test_framework :rspec
      generate.helper false
      generate.stylesheets false
      generate.javascript_engine false
      generate.view_specs false
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    #config.autoload_paths += %W(#{Rails.root}/app/services #{Rails.root}/app/presenters)
    config.autoload_paths += %W(#{Rails.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.compress = !Rails.env.development?
    config.assets.initialize_on_precompile = false
    config.assets.precompile += %w(envb.css)

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.paths << "#{Rails.root}/app/assets/osul"


    # Configure CAS
    config.rubycas.cas_base_url = application_config["rubycas"]["cas_base_url"]
    config.rubycas.validate_url = application_config["rubycas"]["validate_url"]
    config.rubycas.cas_destination_logout_param_name = application_config["rubycas"]["cas_destination_logout_param_name"]

    # Disable implicit joining
    config.active_record.disable_implicit_join_references = true

    # CORS
    config.middleware.use Rack::Cors do
      allow do
        origins /.*\.library\.oregonstate\.edu/
        resource '/*'
      end
    end

    # Don't ignore IPs from local trusted network!
    config.action_dispatch.trusted_proxies = /^127\.0\.0\.1$/ # localhost
  end
end
