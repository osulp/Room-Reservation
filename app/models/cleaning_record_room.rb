class CleaningRecordRoom < ActiveRecord::Base
  belongs_to :cleaning_record
  belongs_to :room
  validates :cleaning_record, :room, :presence => true
  validate :not_overriding_previous_record

  after_save :expire_caches
  after_destroy :expire_caches

  def expire_caches(cleaning_record=nil)
    cleaning_record ||= self.cleaning_record
    EventManager::CleaningRecordsManager.expire_cache(self, cleaning_record)
  end

  private

  def not_overriding_previous_record
    if room && room.cleaning_records.where("start_date <= ? AND end_date >= ?", cleaning_record.start_date, cleaning_record.end_date).length >= 1
      errors.add(:room, "already has a cleaning record for this date range.")
    end
  end

end
