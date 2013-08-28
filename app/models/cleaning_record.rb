class CleaningRecord < ActiveRecord::Base
  attr_accessible :end_date, :end_time, :start_date, :start_time
  serialize :weekdays
  validates :start_date, :end_date, :start_time, :end_time, :presence => true
  validate :start_date_less_than_or_equal_to_end_date
  validate :weekdays_is_array

  has_many :cleaning_record_rooms, :dependent => :destroy
  has_many :rooms, :through => :cleaning_record_rooms

  after_save :expire_presenter
  after_destroy :expire_presenter

  private
  def start_date_less_than_or_equal_to_end_date
    errors.add(:start_date, "must be less than or equal to the end date") unless self.start_date && self.end_date && self.start_date <= self.end_date
  end

  def weekdays_is_array
    errors.add(:weekdays, "must be an array of weekdays") unless weekdays.kind_of?(Array)
  end


  # TODO: MAKE THIS BETTER
  # Right now this is required because cache keys use updated_at, and MySQL only stores updated_at to the second.
  # This can make saving a new cleaning record that affects a large date range take a LONG time.
  def expire_presenter
    start_date = self.start_date
    end_date = self.end_date
    start_date.upto(end_date) do |date|
      time = Time.zone.parse(date.to_s)
      CalendarPresenter.expire_time(time, time.tomorrow.midnight)
    end
  end
end