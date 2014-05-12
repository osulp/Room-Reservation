class Reserver
  module Validations
    extend ActiveSupport::Concern
    included do
      validate :run_validations
      validate :user_not_nil
      validate :room_is_persisted
    end

    def run_validations
      if required_values_exist?
        start_time_less_than_end_time
        reservation_not_in_past
        time_is_available
        duration_correct
        authorized_to_reserve
        concurrency_limit
        day_limit_applied
      end
    end

    def required_values_exist?
      %w{start_time end_time user reserver room user_onid reserver_onid}.map{|x| self.send(x).present?}.inject{|bool, val| bool && val} 
    end

    def user_not_nil
      errors.add(:base, "A username must be chosen to reserve for.") if user.nil?
      errors.add(:base, "Invalid Reserving Party") if reserver.nil?
    end


    def day_limit_applied
      return if day_limit == 0 || reserver_ignores_restrictions?
      if Time.current+day_limit.days < start_time
        errors.add(:base, "You can only make reservations #{day_limit} days in advance")
      end
    end

    # TODO: Evaluate this - what if they have a reservation on the second day when this crosses midnight?
    def concurrency_limit
      return if max_concurrent == 0 || reserver_ignores_restrictions?
      errors.add(:base, "You can only make #{pluralize(max_concurrent, "reservation")} per day.") if current_ongoing_reservations.size >= max_concurrent
    end

    def max_concurrent
      Setting.max_concurrent_reservations.to_i
    end

    def current_ongoing_reservations
      user.reservations.where("start_time <= ? AND end_time >= ? AND start_time >= ? AND reserver_onid = ?", start_time.tomorrow.midnight-1.second, start_time.midnight, start_time.midnight, user.onid)
    end

    def authorized_to_reserve
      return if reserver_ignores_restrictions?
      errors.add(:base, "You are not authorized to reserve on behalf of #{user.onid}") if user.onid.downcase != reserver.onid.downcase
    end

    def duration_correct
      return if reserver_ignores_restrictions?
      errors.add(:base, "The reservation can not be for more than #{(user.max_reservation_time/60/60).to_i} hours") if duration > user.max_reservation_time
    end
    
    def duration
      end_time - start_time
    end

    def start_time_less_than_end_time
      errors.add(:start_time, "must be less than end time") if start_time >= end_time
    end

    def room_is_persisted
      errors.add(:base, "The requested room does not exist.") if !room || !room.persisted?
    end

    def time_is_available
      checker = AvailabilityChecker.new(room, start_time, end_time, @reservation)
      errors.add(:base, "The requested time slot is not available for reservation") unless checker.available?
    end

    def reservation_not_in_past
      return if reserver_ignores_restrictions?
      errors.add(:base, "You may not make reservations in the past.") unless start_time >= Time.current
    end

    # Ability for CanCan
    def reserver_ability
      @reserver_ability ||= Ability.new(reserver)
    end


    def reserver_ignores_restrictions?
      reserver_ability.can?(:ignore_restrictions, self.class)
    end
  end
end
