module Keycards::ReserverModule
  extend ActiveSupport::Concern
  included do
    validate :keycard_validations
    before_reservation_save :add_keycard
  end

  def keycard
    return nil if key_card_key.blank?
    KeyCard.where(:key => key_card_key).first
  end

  protected

  def keycard_validations
    if APP_CONFIG[:keycards][:enabled]
      authorized_to_card
      has_keycard
      keycard_exists
    end
  end

  def add_keycard
    reservation.key_card = keycard
  end

  def authorized_to_card
    return if !reserver || !key_card_key
    errors.add(:base, "You are unable to check out a key card") unless reserver_ability.can?(:assign_keycard,self)
  end

  def has_keycard
    return if !reserver || !key_card_key.blank?
    errors.add(:base, "A key card must be swiped to make this reservation") if reserver_ability.can?(:assign_keycard,self) && !reserver_ability.can?(:manage, self) && !reservation.persisted?
  end

  def keycard_exists
    return if !reserver || key_card_key.blank?
    errors.add(:base, "Invalid keycard.") if !keycard
  end
end