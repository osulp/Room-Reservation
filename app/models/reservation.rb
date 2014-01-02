class Reservation < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail
  belongs_to :room
  has_one :key_card
  before_destroy :touch
  validates :end_time, :start_time, :reserver_onid, :user_onid, :room, presence: true

  def self.active
    joins(:key_card)
  end

  def user
    @user = nil if @user && @user.onid != user_onid
    @user ||= User.new(user_onid)
  end

  def reserver
    @reserver = nil if @reserver && @reserver.onid != reserver_onid
    @reserver ||= User.new(reserver_onid)
  end

  def user=(user)
    if user.respond_to?(:onid)
      self.user_onid = user.onid
      @user = user
    else
      self.user_onid = user.to_s
      @user = nil
    end
  end

  def reserver=(user)
    if user.respond_to?(:onid)
      self.reserver_onid = user.onid
      @reserver = reserver
    else
      self.reserver_onid = user.to_s
      @reserver = nil
    end
  end

  def duration
    self.end_time - self.start_time
  end

  def expired?
    end_time < Time.current
  end

end
