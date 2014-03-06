class Openroom::Keycard < ActiveRecord::Base
  establish_connection "openroom_#{Rails.env}"
  belongs_to :room, :foreign_key => :roomid, :primary_key => :roomid, :class_name => "Openroom::Room"
  has_many :reservations, :foreign_key => :keycardid, :primary_key => :id

  def converted
    k = ::KeyCard.where(:key => barcode).first || ::KeyCard.new
    k.key = barcode
    k
  end
end
