class Keycards::CheckinService
  include ActiveModel::Model
  attr_accessor :keycard, :user
  validate :user_can_checkin

  def initialize(keycard, user)
    self.keycard = keycard
    self.user = user
  end

  def user=(user)
    if user.kind_of?(String)
      user = User.new(user)
    end
    @user = user
  end

  def save
    return false unless valid?
    true
  end

  private

  def user_can_checkin
    errors.add(:base, "You are unauthorized to check in a key card.") unless user_ability.can?(:check_in, keycard)
  end

  def user_ability
    @user_ability ||= Ability.new(user)
  end
end
