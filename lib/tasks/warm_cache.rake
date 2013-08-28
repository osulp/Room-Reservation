namespace :roomreservation do
  desc "Warm 3 months before to 3 months after in the cache"
  task :warm_cache => :environment do
    start_date = 90.days.ago.to_date
    end_date = 90.days.from_now.to_date
    c = ApplicationController.new
    start_date.upto(end_date) do |date|
      presenter = CalendarPresenter.cached(Time.zone.parse(date.to_s), Time.zone.parse((date+1.day).to_s))
      c.instance_variable_set(:@presenter, presenter)
      c.render_to_string(:partial => "home/room_list")
    end
  end
end