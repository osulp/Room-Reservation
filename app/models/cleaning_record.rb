class CleaningRecord < ApplicationRecord
  acts_as_paranoid
  has_paper_trail
  before_destroy :touch
  serialize :weekdays
  validates :start_date, :end_date, :start_time, :end_time, :presence => true
  validate :start_date_less_than_or_equal_to_end_date
  validate :start_time_less_than_or_equal_to_end_time
  validate :weekdays_is_array

  has_many :cleaning_record_rooms, :dependent => :destroy
  has_many :rooms, :through => :cleaning_record_rooms

  private
  def start_date_less_than_or_equal_to_end_date
    errors.add(:start_date, "must be less than or equal to the end date") unless self.start_date && self.end_date && self.start_date <= self.end_date
  end

  def start_time_less_than_or_equal_to_end_time
    errors.add(:start_time, "must be less than or equal to the end time") unless self.start_time && self.end_time && self.start_time <= self.end_time

  end

  def weekdays_is_array
    errors.add(:weekdays, "must be an array of weekdays") unless weekdays.kind_of?(Array)
  end
end
