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
    return @user_name if @user_name
    u = object.user
    u.banner_record = object.user_banner_record || BannerRecord.new
    @user_name ||= u.decorate.name
  end

  def cancel_string
    return {} unless show_view?
    object.decorate.cancel_string
  end

  def available_times
    return {} unless show_view?
    object.decorate.available_times
  end

  private

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  # This is done so that the more complicated calculations don't happen in the bulk reservation query.
  def show_view?
    object.class == Reservation
  end
end
