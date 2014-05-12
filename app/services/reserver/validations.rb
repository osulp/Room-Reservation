class Reserver
  module Validations
    extend ActiveSupport::Concern
    included do
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

    # Ability for CanCan
    def reserver_ability
      @reserver_ability ||= Ability.new(reserver)
    end
  end
end
