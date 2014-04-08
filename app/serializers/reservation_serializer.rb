class ReservationSerializer < ActiveModel::Serializer
  attributes :id, :reserver_onid, :user_onid, :start_time, :end_time, :room_id, :description, :cancel_string, :user_name, :available_times
  has_one :room
  has_one :key_card

  def attributes
    hash = super
    unless current_ability.can?(:manage, Reservation)
      hash.except!(:room_id, :reserver_onid, :available_times)
    end
    return hash
  end

  def user_name
    object.user.decorate.name
  end

  def cancel_string
    object.decorate.cancel_string
  end

  def available_times
    object.decorate.available_times
  end

  private

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end
end
