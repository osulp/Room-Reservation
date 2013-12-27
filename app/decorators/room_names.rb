module RoomNames
  def room_names
    room_names = []
    rooms.order(:floor, :name).group_by(&:floor).each do |floor, floor_rooms|
      mapped_names = floor_rooms.map(&:name)
      if floor_rooms.map{|x| x.name} == organized_floors[floor]
        room_names << "Floor #{floor}"
      else
        room_names |= mapped_names
      end
    end
    room_names
  end
end