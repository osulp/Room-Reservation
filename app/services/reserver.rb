class Reserver
  include ActiveModel::Model
  include(Keycards::ReserverModule) if APP_CONFIG[:keycards][:enabled]
  validates :start_time, :end_time, :room, :reserver, :reserved_for, :presence => true
  validate :user_not_nil
  validate :start_time_less_than_end_time
  validate :reservation_not_in_past
  validate :room_is_persisted
  validate :time_is_available
  validate :duration_correct
  validate :authorized_to_reserve
  validate :concurrency_limit
  validate :append_reservation_errors

  # Callbacks
  define_model_callbacks :reservation_save

  ATTRIBUTES = [:reserver_onid, :user_onid, :room_id, :start_time, :end_time, :description, :key_card_key]
  attr_accessor *ATTRIBUTES
  attr_accessor :reserver, :reserved_for, :room
  attr_reader :reservation

  delegate :as_json, :read_attribute_for_serialization, :to => :reservation

  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
    self.reserver = UserDecorator.new(User.new(reserver_onid)) if reserver_onid
    self.reserved_for = UserDecorator.new(User.new(user_onid)) if user_onid
    self.room = Room.where(:id => room_id).first
  end

  def start_time=(value)
    @start_time = value if value.blank?
    @start_time = Time.zone.parse(value.to_s)
  end

  def end_time=(value)
    @end_time = value if value.blank?
    @end_time = Time.zone.parse(value.to_s)
  end

  def save
    return false unless valid?
    @reservation ||= Reservation.new
    @reservation.update_attributes(:user_onid => reserved_for.onid,
                                   :reserver_onid => reserver.onid,
                                   :room => room,
                                   :start_time => start_time,
                                   :end_time => end_time,
                                   :description => description)
    run_callbacks :reservation_save do
      @reservation.save
    end
  end

  def persisted?
    reservation.persisted?
  end

  def reservation
    @reservation || Reservation.new
  end

  private

  def user_not_nil
    return if !reserved_for || !reserver
    errors.add(:base, "A username must be chosen to reserve for.") if reserved_for.nil?
    errors.add(:base, "Invalid Reserving Party") if reserver.nil?
  end

  # TODO: Evaluate this - what if they have a reservation on the second day when this crosses midnight?
  def concurrency_limit
    max_concurrent = APP_CONFIG["reservations"]["max_concurrent_reservations"].to_i
    return if !reserved_for || !reserver || max_concurrent == 0 || reserver_ability.can?(:ignore_restrictions,self)
    current_reservations = reserved_for.reservations.where("start_time <= ? AND end_time >= ? AND start_time >= ?", start_time.tomorrow.midnight-1.second, start_time.midnight, start_time.midnight).size
    errors.add(:base, "You can only make #{max_concurrent} reservations per day.") if current_reservations >= max_concurrent
  end

  def authorized_to_reserve
    return if !reserved_for || !reserver || reserver_ability.can?(:ignore_restrictions,self)
    errors.add(:base, "You are not authorized to reserve on behalf of #{reserved_for.onid}") if reserved_for.onid.downcase != reserver.onid.downcase
  end

  def duration_correct
    return if !end_time || !start_time || !reserved_for || !reserver || reserver_ability.can?(:ignore_restrictions,self)
    duration = end_time - start_time
    errors.add(:base, "The reservation can not be for more than #{(reserved_for.max_reservation_time/60/60).to_i} hours") if duration > reserved_for.max_reservation_time
  end

  def start_time_less_than_end_time
    errors.add(:start_time, "must be less than end time") if start_time && end_time && start_time >= end_time
  end

  def room_is_persisted
    errors.add(:base, "The requested room does not exist.") if !room || !room.persisted?
  end

  def time_is_available
    checker = AvailabilityChecker.new(room, start_time, end_time)
    return if !room || !start_time || !end_time
    errors.add(:base, "The requested time slot is not available for reservation") unless checker.available?
  end

  def reservation_not_in_past
    return if !start_time || !reserver || reserver_ability.can?(:ignore_restrictions,self)
    errors.add(:base, "You may not make reservations in the past.") unless start_time >= Time.current
  end

  def append_reservation_errors
    return if !reservation
    unless reservation.valid?
      reservation.errors.full_messages.each do |msg|
        self.errors.add(:base, msg)
      end
    end
  end

  # Ability for CanCan
  def reserver_ability
    @reserver_ability ||= Ability.new(reserver)
  end

end
