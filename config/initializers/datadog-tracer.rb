# frozen_string_literal: true

if %w[production staging].include? Rails.env
  Datadog.configure do |c|
    c.use :rails, service_name: "room-reservation-#{Rails.env}"
    c.use :http, service_name: "room-reservation-#{Rails.env}-http"
    c.use :redis, service_name: "room-reservation-#{Rails.env}-redis"
    c.use :sidekiq, service_name: "room-reservation-#{Rails.env}-sidekiq"
  end
end
