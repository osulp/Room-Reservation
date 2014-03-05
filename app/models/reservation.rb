class Reservation < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail
  belongs_to :room
  has_one :key_card
  before_destroy :touch
  validates :end_time, :start_time, :reserver_onid, :user_onid, :room, presence: true
  validate :not_swearing
  validate :key_card_valid

  def self.active
    joins(:key_card)
  end

  def self.inactive
    includes(:key_card).references(:key_cards).where("key_cards.id IS NULL")
  end

  def self.ongoing
    where("start_time <= ? AND end_time >= ?", Time.current, Time.current)
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

  def current_originator
    return originator if !version
    version.originator
  end

  protected

  def key_card_valid
    return unless key_card
    key_card.reservation = self
    unless key_card.valid?
      key_card.errors.full_messages.each do |msg|
        self.errors.add(:base, msg)
      end
    end
  end

  def not_swearing
    errors.add(:description, "is innapropriate.") if SwearFilter.profane?(description)
  end

end
