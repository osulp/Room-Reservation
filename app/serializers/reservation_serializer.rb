class ReservationSerializer < ActiveModel::Serializer
  attributes :id, :reserver_onid, :user_onid, :start_time, :end_time, :room_id
  has_one :room

  def attributes
    hash = super
    unless current_user.admin?
      hash.except!(:room_id, :reserver_onid)
    end
    return hash
  end
end
