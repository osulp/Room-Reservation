class RoomHourDecorator < Draper::Decorator
  include RoomNames
  delegate_all

  def date_range
    "#{start_date.strftime("%m/%d/%y")} - #{end_date.strftime("%m/%d/%y")}"
  end

  def hours_string
    times_to_text(start_time, end_time)
  end

  def room_collection
    room_selection
  end

  def floor_selection
    all_rooms.map{|x| x.floor.to_i}.uniq.sort.map{|x| ["Floor #{x}", "floor_#{x}", x]}
  end

  private

  # TODO: Extract/Refactor this.
  def times_to_text(start_time, end_time)
    start_time = start_time.utc.strftime("%l:%M %P").strip
    end_time = end_time.utc.strftime("%l:%M %P").strip
    times = {'open' => start_time, 'close' => end_time}
    special = '12:15 am'
    one = '1:00 am'
    midnight = '12:00 am'
    case
      when times['open'] == one && times['close'] == one
        resultString = 'Closed'
      when times['open'] == midnight && times['close'] == midnight
        resultString = 'Open 24 hours'
      when times['open'] == special
        resultString = "Closes #{times['close']}"
      when times['close'] == special
        resultString = "#{times['open']} - no closing"
      else
        resultString = "#{times['open']} - #{times['close']}"
    end
    return resultString || ''
  end

  def organized_floors
    @organized_floors ||= Room.all.order(:name).pluck(:name, :floor).group_by{|x| x[1]}.each_with_object({}) {|(key, value), hsh| hsh[key] = value.map{|x| x[0]}}
  end

  def all_rooms
    @all_rooms ||= Room.order(:name)
  end

  def room_selection
    all_rooms.map{|x| [x.name, x.id, {:data => {:floor => x.floor}}]}
  end
end
