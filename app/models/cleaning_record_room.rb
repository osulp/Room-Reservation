class CleaningRecordRoom < ApplicationRecord
  belongs_to :cleaning_record, :touch => true, optional: true
  belongs_to :room, optional: true
  validate :not_overriding_previous_record

  private

  def not_overriding_previous_record
    if room && cleaning_record && room.cleaning_records.where("start_date <= ? AND end_date >= ? AND cleaning_records.id != ?", cleaning_record.start_date, cleaning_record.end_date, cleaning_record.id).length >= 1
      errors.add(:room, "already has a cleaning record for this date range.")
    end
  end

end
