class Reservation < ActiveRecord::Base
  belongs_to :room
  attr_accessible :description, :end_time, :reserver_onid, :start_time, :user_onid, :room
  validates :end_time, :start_time, :reserver_onid, :user_onid, presence: true

  def duration
    self.end_time - self.start_time
  end

end
