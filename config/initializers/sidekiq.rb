Sidekiq.configure_server do |config|
  config.redis = {:url => 'redis://redis:6379',:namespace => "roomreservation"}
end

Sidekiq.configure_client do |config|
  config.redis = {:url => 'redis://redis:6379',:namespace => "roomreservation"}
end
