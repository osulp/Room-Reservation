class Reservation < ActiveRecord::Base
  belongs_to :room_id
    attr_accessible :description, :end_time, :reserver_onid, :start_time, :user_onid
    validates :description, :end_time, :start_time, :reserver_onid, :user_onid, presence: true
    validates :user_onid, :reserver_onid, numericality: {only_integer: true}
end
