class CacheCalendarPresenter
  include Sidekiq::Worker
  def perform(start_time, end_time, key, skip_publish)
    start_time = Time.zone.at(start_time)
    end_time = Time.zone.at(end_time)
    unless Rails.cache.exist?(key, :deserialize => false)
      presenter = CalendarPresenter.new(start_time, end_time)
      presenter.rooms
      Rails.cache.write(key, presenter)
      CalendarPresenter.publish_changed(start_time, end_time, key) unless skip_publish
    end
  end
end
