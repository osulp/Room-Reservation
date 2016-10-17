class Openroom::User < ApplicationRecord
  establish_connection "openroom_#{Rails.env}"
  has_many :reservations, :foreign_key => :username, :primary_key => :username, :class_name => "Openroom::Reservation"
end
