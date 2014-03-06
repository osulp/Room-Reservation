class Openroom::Reservation < ActiveRecord::Base
  establish_connection "openroom_#{Rails.env}"
  belongs_to :user, :foreign_key => :username, :primary_key => :username, :class_name => "Openroom::User"
  belongs_to :room, :foreign_key => :roomid, :primary_key => :roomid, :class_name => "Openroom::Room"
  has_one :description, :class_name => "Openroom::Description", :foreign_key => :reservationid, :primary_key => :reservationid
  has_one :keycard, :class_name => "Openroom::Keycard", :foreign_key => :barcode, :primary_key => :keycardid

  def converted
    r = ::Reservation.where(:user_onid => username, :start_time => converted_start, :end_time => converted_end).first || ::Reservation.new
    r.start_time = converted_start
    r.end_time = converted_end
    r.description = description.optionvalue unless !description || description.optionvalue.blank?
    r.description = nil if SwearFilter.profane?(r.description)
    r.reserver_onid = "Legacy Import"
    r.user_onid = username
    r.room = room.converted
    if keycard
      r.key_card = keycard.converted
      r.key_card.reservation = r
    end
    r
  end

  def converted_start
    start + 10.minutes
  end

  def converted_end
    self.end + 1.second
  end

end
