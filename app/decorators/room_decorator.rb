class RoomDecorator < Draper::Decorator
  delegate_all

  def filter_string
    string = ""
    filters.each do |filter|
      string += "room-filter-#{filter.id}"
    end
    string.strip
  end

end
