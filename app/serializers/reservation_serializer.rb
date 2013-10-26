class ReservationSerializer < ActiveModel::Serializer
  attributes :id, :reserver_onid, :user_onid, :start_time, :end_time, :room_id
  has_one :room
end
