class Reservation
  module Validations
    extend ActiveSupport::Concern
    included do
      validates :end_time, :start_time, :reserver_onid, :user_onid, :room, presence: true
      validate :not_swearing
      validate :key_card_valid
    end

    def key_card_valid
      return unless key_card
      key_card.reservation = respond_to?(:reservation) ? reservation : self
      unless key_card.valid?
        key_card.errors.full_messages.each do |msg|
          self.errors.add(:base, msg)
        end
      end
    end

    def not_swearing
      errors.add(:description, "is inappropriate.") if SwearFilter.profane?(description)
    end

  end
end
