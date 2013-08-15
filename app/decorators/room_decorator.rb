class RoomDecorator < Draper::Decorator
  delegate_all
  attr_accessor :presenter

  def filter_string
    string = ""
    filters.each do |filter|
      string += "filter-#{filter.id} "
    end
    string.strip
  end

end
