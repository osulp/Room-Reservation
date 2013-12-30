class CleaningRecordDecorator < Draper::Decorator
  include RoomNames
  delegate_all

  def date_range
    "#{start_date.strftime("%m/%d/%y")} - #{end_date.strftime("%m/%d/%y")}"
  end

  def time_range
    "#{start_time.utc.strftime("%l:%M %p")} - #{end_time.utc.strftime("%l:%M %p")}"
  end

  def room_collection
    room_selection
  end

  def floor_selection
    all_rooms.map{|x| x.floor.to_i}.uniq.sort.map{|x| ["Floor #{x}", "floor_#{x}", x]}
  end

  private

  def organized_floors
    @organized_floors ||= Room.all.order(:name).pluck(:name, :floor).group_by{|x| x[1]}.each_with_object({}) {|(key, value), hsh| hsh[key] = value.map{|x| x[0]}}
  end

  def all_rooms
    @all_rooms ||= Room.all
  end

  def room_selection
    all_rooms.map{|x| [x.name, x.id, {:data => {:floor => x.floor}}]}
  end
end
