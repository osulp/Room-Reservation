class Reserver
  include ActiveModel::Model
  include ActionView::Helpers::TextHelper
  # Callbacks
  define_model_callbacks :reservation_save
  # Keycard Include
  include Keycards::ReserverModule
  # Validations
  validates :start_time, :end_time, :room, :reserver_onid, :user_onid, :presence => true
  validate :user_not_nil
  validate :start_time_less_than_end_time
  validate :reservation_not_in_past
  validate :room_is_persisted
  validate :time_is_available
  validate :duration_correct
  validate :authorized_to_reserve
  validate :concurrency_limit
  validate :append_reservation_errors
  validate :day_limit_applied

  delegate :reserver, :user, :reserver_onid, :user_onid, :room_id, :room, :start_time, :end_time, :description, :key_card, :decorate, :to => :reservation
  delegate :start_time=, :end_time=, :room=, :reserver=, :user=, :reserver_onid=, :user_onid=, :to => :reservation
  attr_accessor :key_card_key
  attr_reader :reservation

  delegate :as_json, :read_attribute_for_serialization, :to => :reservation
  after_reservation_save :send_email
  before_reservation_save :reset_truncated_at


  def self.reflect_on_association(association)
    Reservation.reflect_on_association(association)
  end

  def self.model_name
    Reservation.model_name
  end

  def initialize(attributes = {},options={})
    @options = options
    if attributes.kind_of?(Reservation)
      @reservation = attributes
      return
    end
    self.key_card_key = attributes.delete(:key_card_key)
    @reservation ||= Reservation.new
    @reservation.attributes = attributes
  end

  def save
    return false unless valid?
    @reservation ||= Reservation.new

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

  def send_email
    return if @options[:ignore_email]
    unless user.email.blank?
      begin
        ReservationMailer.delay.send(email_method, reservation, user.decorate)
      rescue Redis::CannotConnectError
        return
      end
    end
  end

  def email_method
    @email_method ||= begin
      return @options[:email_method] unless @options[:email_method].blank?
      if reservation.versions.size > 1
        :update_email
      else
        :reservation_email
      end
    end
  end

  def day_limit
    (Setting.day_limit || 0).to_i
  end

  def day_limit_applied
    return if !start_time || day_limit == 0 || !reserver || reserver_ability.can?(:ignore_restrictions,self.class)
    if Time.current+day_limit.days < start_time
      errors.add(:base, "You can only make reservations #{day_limit} days in advance")
    end
  end

  def user_not_nil
    return if !user || !reserver
    errors.add(:base, "A username must be chosen to reserve for.") if user.nil?
    errors.add(:base, "Invalid Reserving Party") if reserver.nil?
  end

  # TODO: Evaluate this - what if they have a reservation on the second day when this crosses midnight?
  def concurrency_limit
    max_concurrent = Setting.max_concurrent_reservations.to_i
    return if !user || !reserver || !start_time || max_concurrent == 0 || reserver_ability.can?(:ignore_restrictions,self.class)
    current_reservations = user.reservations.where("start_time <= ? AND end_time >= ? AND start_time >= ? AND reserver_onid = ?", start_time.tomorrow.midnight-1.second, start_time.midnight, start_time.midnight, user.onid).size
    errors.add(:base, "You can only make #{pluralize(max_concurrent, "reservation")} per day.") if current_reservations >= max_concurrent
  end

  def authorized_to_reserve
    return if !user || !reserver || reserver_ability.can?(:ignore_restrictions,self.class) || !user_onid || !reserver_onid
    errors.add(:base, "You are not authorized to reserve on behalf of #{user.onid}") if user.onid.downcase != reserver.onid.downcase
  end

  def duration_correct
    return if !end_time || !start_time || !user || !reserver || reserver_ability.can?(:ignore_restrictions,self.class)
    duration = end_time - start_time
    errors.add(:base, "The reservation can not be for more than #{(user.max_reservation_time/60/60).to_i} hours") if duration > user.max_reservation_time
  end

  def start_time_less_than_end_time
    errors.add(:start_time, "must be less than end time") if start_time && end_time && start_time >= end_time
  end

  def room_is_persisted
    errors.add(:base, "The requested room does not exist.") if !room || !room.persisted?
  end

  def time_is_available
    checker = AvailabilityChecker.new(room, start_time, end_time, @reservation)
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

  def reset_truncated_at
    if reservation.changed? && !reservation.truncated_at_changed?
      reservation.truncated_at = nil
    end
  end

  # Ability for CanCan
  def reserver_ability
    @reserver_ability ||= Ability.new(reserver)
  end

end
