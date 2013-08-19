RSpec.configure do |config|
  config.around(:each, :caching => true) do |example|
    caching, ActionController::Base.perform_caching = ActionController::Base.perform_caching, true
    store, ActionController::Base.cache_store = ActionController::Base.cache_store, :memory_store
    silence_warnings { Object.const_set "RAILS_CACHE", ActionController::Base.cache_store }

    example.run

    silence_warnings { Object.const_set "RAILS_CACHE", store }
    ActionController::Base.cache_store = store
    ActionController::Base.perform_caching = caching
  end
end