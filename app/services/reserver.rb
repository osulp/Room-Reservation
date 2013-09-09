class Reserver
  include ActiveModel::Validations

  validates :start_time, :end_time, :room, :reserver, :reserved_for, :presence => true
  validate :start_time_less_than_end_time
  validate :room_is_persisted
  validate :time_is_available
  validate :duration_correct

  attr_accessor :reserver, :reserved_for, :room, :start_time, :end_time
  attr_reader :reservation

  def self.from_params(params)
    reservation_params = params[:reservation]
    self.new(
        User.new(reservation_params[:reserver_onid]),
        User.new(reservation_params[:user_onid]),
        Room.find(reservation_params[:room_id]),
        Time.zone.parse(reservation_params[:start_time]),
        Time.zone.parse(reservation_params[:end_time])
    )
  end
  def initialize(reserver, reserved_for, room, start_time, end_time)
    @reserver = UserDecorator.new(reserver)
    @reserved_for = UserDecorator.new(reserved_for)
    @room = room
    @start_time = start_time
    @end_time = end_time
  end

  def save
    return false unless valid?
    @reservation ||= Reservation.new
    @reservation.update_attributes(:user_onid => reserved_for.onid,
                                   :reserver_onid => reserver.onid,
                                   :room => room,
                                   :start_time => start_time,
                                   :end_time => end_time)
    @reservation.save
  end

  private

  def duration_correct
    return if !end_time || !start_time || !reserved_for
    duration = end_time - start_time
    errors.add(:base, "The reservation can not be for more than #{(reserved_for.max_reservation_time/60/60).to_i} hours") if duration > reserved_for.max_reservation_time
  end

  def start_time_less_than_end_time
    errors.add(:start_time, "must be less than end time") if start_time && end_time && start_time >= end_time
  end

  def room_is_persisted
    errors.add(:room, "must be persisted") if room && !room.persisted?
  end

  def time_is_available
    checker = AvailabilityChecker.new(room, start_time, end_time)
    return if !room || !start_time || !end_time
    errors.add(:base, "The requested time slot is not available for reservation") unless checker.available?
  end

end