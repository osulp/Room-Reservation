class Reservation < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :room
  before_destroy :touch
  validates :end_time, :start_time, :reserver_onid, :user_onid, :room, presence: true

  def duration
    self.end_time - self.start_time
  end

end
