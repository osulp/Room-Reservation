class CleaningRecordDecorator < Draper::Decorator
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

  def room_names
    room_names = []
    rooms.group_by(&:floor).each do |floor, floor_rooms|
      mapped_names = floor_rooms.map(&:name)
      if floor_rooms.map{|x| x.name} == organized_floors[floor]
        room_names << "Floor #{floor}"
      else
        room_names |= mapped_names
      end
    end
    room_names
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
