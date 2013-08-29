class CleaningRecord < ActiveRecord::Base
  attr_accessible :end_date, :end_time, :start_date, :start_time
  serialize :weekdays
  validates :start_date, :end_date, :start_time, :end_time, :presence => true
  validate :start_date_less_than_or_equal_to_end_date
  validate :weekdays_is_array

  has_many :cleaning_record_rooms, :dependent => :destroy
  has_many :rooms, :through => :cleaning_record_rooms

  private
  def start_date_less_than_or_equal_to_end_date
    errors.add(:start_date, "must be less than or equal to the end date") unless self.start_date && self.end_date && self.start_date <= self.end_date
  end

  def weekdays_is_array
    errors.add(:weekdays, "must be an array of weekdays") unless weekdays.kind_of?(Array)
  end
end