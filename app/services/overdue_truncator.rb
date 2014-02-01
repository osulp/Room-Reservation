class OverdueTruncator
  def self.call
    self.new.perform_truncation!
  end

  def perform_truncation!
    PaperTrail.whodunnit = "Truncator"
    ranges = []
    Reservation.transaction do
      eligible_reservations.each do |reservation|
        reservation.truncated_at = Time.current
        reservation.save!
        ranges << (reservation.start_time.to_date..reservation.end_time.to_date)
      end
    end
    notify_updates(ranges)
  end

  private

  def notify_updates(ranges)
    merge_ranges(ranges).each do |range|
      CalendarPresenter.publish_changed(range.first, range.last) if range
    end
  end

  def eligible_reservations
    @eligible_reservations ||= Reservation.ongoing.inactive.where("start_time < ? AND truncated_at IS NULL", Time.current-truncate_limit)
  end

  # TODO: Move to configuration.
  def truncate_limit
    15.minutes
  end

  def merge_ranges(ranges)
  ranges = ranges.sort_by {|r| r.first }
  *outages = ranges.shift
  ranges.each do |r|
    lastr = outages[-1]
    if lastr.last >= r.first - 1
      outages[-1] = lastr.first..[r.last, lastr.last].max
    else
      outages.push(r)
    end
  end
  outages.compact
end

end