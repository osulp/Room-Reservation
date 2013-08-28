class RoomHourRecord < ActiveRecord::Base
  belongs_to :room
  belongs_to :room_hour, :touch => true

  after_create :expire_presenter

  protected

  def expire_presenter
    room_hour.send(:expire_presenter)
  end
end
