class CacheCalendarPresenter
  include Sidekiq::Worker
  def perform(start_time, end_time, key, skip_publish, ignore_managers=nil)
    start_time = Time.zone.at(start_time)
    end_time = Time.zone.at(end_time)
    Array.wrap(ignore_managers).map!{|x| x.constantize if x.kind_of?(String)}
    unless Rails.cache.exist?(key, :deserialize => false)
      presenter = CalendarPresenter.new(start_time, end_time, nil, ignore_managers)
      presenter.rooms
      Rails.cache.write(key, presenter)
    end
  end
end
