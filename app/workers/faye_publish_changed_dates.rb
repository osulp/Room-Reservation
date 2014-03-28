class FayePublishChangedDates
  include Sidekiq::Worker

  def perform(start_time, end_time, presenter_key=nil)
    if presenter_key
      cached_presenter = Rails.cache.read(presenter_key)
    end
    start_time = start_time.to_date
    end_time = ((end_time).to_date-1.minute).to_date unless end_time.kind_of?(Date)
    notifier = DateUpdateNotifier.new
    start_time.upto(end_time) do |date|
      cached_presenter ||= CalendarPresenter.cached(date.midnight, date.tomorrow.midnight,true)
      notifier.notify_update(date,cached_presenter)
    end
  end
end
