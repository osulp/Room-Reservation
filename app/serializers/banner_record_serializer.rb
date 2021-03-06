class BannerRecordSerializer < ActiveModel::Serializer
  attributes :onid, :status, :fullName, :max_reservation_time

  def max_reservation_time
    User.new(object.onid).max_reservation_time
  end
end
