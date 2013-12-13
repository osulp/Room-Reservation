class Reservation < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :room
  has_one :key_card
  before_destroy :touch
  validates :end_time, :start_time, :reserver_onid, :user_onid, :room, presence: true

  def self.active
    joins(:key_card)
  end

  def user
    User.new(user_onid)
  end
  def reserver
    User.new(reserver_onid)
  end

  def duration
    self.end_time - self.start_time
  end

end
