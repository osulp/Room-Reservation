class CleaningRecordRoom < ActiveRecord::Base
  belongs_to :cleaning_record, :touch => true
  belongs_to :room
  validates :cleaning_record, :room, :presence => true
  validate :not_overriding_previous_record

  private

  def not_overriding_previous_record
    if room && room.cleaning_records.where("start_date <= ? AND end_date >= ?", cleaning_record.start_date, cleaning_record.end_date).length >= 1
      errors.add(:room, "already has a cleaning record for this date range.")
    end
  end

end
