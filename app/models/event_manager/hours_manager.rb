class EventManager::HoursManager < EventManager::EventManager
  def hours(date)
    result = {}
    self.class.hour_models.each do |hour_model|
      result = hour_model.time_info(date)[date]
      break unless result.blank?
    end
    return result
  end

  private

  def self.hour_models
    [
        Hours::Hour,
        Hours::IntersessionHour,
        Hours::SpecialHour
    ].sort_by(&:priority).reverse!
  end
end
