class Reservation < ActiveRecord::Base
  belongs_to :room, :touch => true
  attr_accessible :description, :end_time, :reserver_onid, :start_time, :user_onid
  validates :description, :end_time, :start_time, :reserver_onid, :user_onid, presence: true

  def duration
    self.end_time - self.start_time
  end

end
