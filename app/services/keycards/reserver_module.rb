module Keycards::ReserverModule
  extend ActiveSupport::Concern
  included do
    validate :authorized_to_card
    validate :has_keycard
    validate :keycard_exists

    before_reservation_save :add_keycard
  end

  def keycard
    KeyCard.where(:key => key_card_key).first
  end

  protected

  def add_keycard
    reservation.key_card = keycard
  end

  def authorized_to_card
    return if !reserver || !key_card_key
    errors.add(:base, "You are unable to check out a key card") unless reserver_ability.can?(:assign_keycard,self)
  end

  def has_keycard
    return if !reserver || !key_card_key.blank?
    errors.add(:base, "A key card must be swiped to make this reservation") if reserver_ability.can?(:assign_keycard,self) && !reserver_ability.can?(:manage, self)
  end

  def keycard_exists
    return if !reserver || key_card_key.blank?
    errors.add(:base, "Invalid keycard.") if !keycard
  end
end