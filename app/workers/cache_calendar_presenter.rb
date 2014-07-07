class CacheCalendarPresenter
  include Sidekiq::Worker
  def perform(start_time, end_time, key, skip_publish, ignore_managers=nil)
    start_time = Time.zone.at(start_time)
    end_time = Time.zone.at(end_time)
    ignore_managers.map!{|x| x.constantize if x.kind_of?(String)}
    unless Rails.cache.exist?(key, :deserialize => false)
      presenter = CalendarPresenter.new(start_time, end_time, nil, ignore_managers)
      presenter.rooms
      Rails.cache.write(key, presenter)
      CalendarPresenter.publish_changed(start_time, end_time, key) unless skip_publish
    end
  end
end
