class CleaningRecordDecorator < Draper::Decorator
  delegate_all

  def date_range
    "#{start_date.strftime("%m/%d/%y")} - #{end_date.strftime("%m/%d/%y")}"
  end

  def time_range
    "#{start_time.utc.strftime("%l:%M %p")} - #{end_time.utc.strftime("%l:%M %p")}"
  end

  def room_collection
    #all_rooms_selection | floor_selection | room_selection
    room_selection
  end

  def all_rooms_selection
    [["All Rooms", nil, {:data => {:all => true}}]]
  end

  def floor_selection
    all_rooms.map{|x| x.floor.to_i}.uniq.sort.map{|x| ["Floor #{x}", "floor_#{x}", x]}
  end

  private

  def all_rooms
    @all_rooms ||= Room.all
  end

  def room_selection
    all_rooms.map{|x| [x.name, x.id, {:data => {:floor => x.floor}}]}
  end
end
