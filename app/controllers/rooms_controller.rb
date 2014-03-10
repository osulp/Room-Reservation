class RoomsController < ApplicationController
  respond_to :json
  def free_times
    rooms = Room.all
    start_date = Time.zone.parse(params[:startDate]).to_date
    end_date = Time.zone.parse(params[:endDate]).to_date
    hash = {}
    start_date.upto end_date do |date|
      time = Time.zone.parse(date.to_s)
      presenter = CalendarPresenter.cached(time.midnight, time.tomorrow.midnight)
      presenter.rooms.each do |room|
        hash[room.name] ||= {date.to_s => []}
        room.decorated_events(time).each do |event|
          if event.kind_of?(AvailableDecorator)
            hash[room.name][date.to_s] << {"start" => event.start_time.iso8601, "end" => event.end_time.iso8601}
          end
        end
      end
    end
    respond_with hash
  end
end
