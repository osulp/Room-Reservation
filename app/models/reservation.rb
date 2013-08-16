class Reservation < ActiveRecord::Base
  belongs_to :room
  after_save :expire_caches
  attr_accessible :description, :end_time, :reserver_onid, :start_time, :user_onid
  validates :description, :end_time, :start_time, :reserver_onid, :user_onid, presence: true

  def duration
    self.end_time - self.start_time
  end

  def expire_caches
    EventManager::ReservationManager.expire_cache(self)
  end

end
