class Room < ActiveRecord::Base
  attr_accessible :floor, :name
  validates :floor, :name, presence: true
  validates :floor, numericality: {only_integer: true}
  has_many :reservations
  has_many :room_filters
  has_many :filters, :through => :room_filters
  has_many :cleaning_record_rooms, :dependent => :destroy
  has_many :cleaning_records, :through => :cleaning_record_rooms

  def load_reservations_today day
    end_of_day = day.end_of_day
    midnight = day.midnight
    @reservations_today = self.reservations.where('start_time < ? AND end_time > ?', end_of_day, midnight).to_a
    @reservations_today.each do |r|
      r.start_time = midnight if r.start_time < midnight
      r.end_time = end_of_day if r.end_time > end_of_day
    end
    @reservations_today
  end

  def load_special_hours_today day
    midnight = day.midnight
    @special_hours = []
    @special_hours <<= Reservation.new :start_time => midnight, :end_time => midnight + 6.hours, :reserver_onid => 'drupal', :user_onid => '_schedule', :description => 'Library closed'
    @special_hours <<= Reservation.new :start_time => midnight + 20.hours, :end_time => midnight + 24.hours, :reserver_onid => 'drupal', :user_onid => '_schedule', :description => 'Library closed'
    @special_hours <<= Reservation.new :start_time => midnight + 8.hours, :end_time => midnight + 9.hours, :reserver_onid => 'admin1', :user_onid => '_maintainance', :description => 'Room cleaning'
    @special_hours
  end

  def load_hours_today day
    load_reservations_today day
    load_special_hours_today day
  end

  def hours_today
    @hours_today ||= (@reservations_today + @special_hours).sort_by { |r| r.start_time }
  end
end
