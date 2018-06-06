require 'csv'

namespace :roomreservation do
  desc "Export room reservation stats for data-dashboard"
  task :export_stats => :environment do
    # get stats for current 12 months
    start_date = 12.months.ago.to_date
    end_date = Date.yesterday

    # # get stats for previous 12 months
    # start_date = 24.months.ago.to_date
    # end_date = 12.months.ago.to_date
    
    csv_output_path = File.join(Rails.root, 'tmp', 'res-stats-data-dashboard.csv')

    CSV.open(csv_output_path, 'ab') do |csv|
      (start_date..end_date).select{|date| date.day == 1}.each do |date|
        # i.e. year_month = "201805"
        year_month = "#{date.year}#{date.strftime('%m')}"

        # i.e. month = "May"
        month = "#{date.strftime('%Y-%b')}"

        begin
          puts "Processing year_month: #{year_month}"

          # get all reservations from year_month
          m = Reservation.where("EXTRACT(YEAR_MONTH FROM start_time) = ?", year_month)

          # get all ids that would include both truncated and checked-in reservations
          ids = m.where.not(truncated_at:nil).pluck(:id)

          # get all checked-in ids by getting all versions on all ids, excluding
          # null objects, and "Truncator" originators, which is applied to truncated
          # reservations only
          r = PaperTrail::Version.where(item_type: 'Reservation', item_id: ids).where.not(object:nil, whodunnit:"Truncator").pluck(:item_id)

          # remove duplicates and get total count for the month
          total_count = r.uniq.count

          csv << [month, total_count]

        rescue => e
          puts "ERROR with year_month: #{year_month} : #{e}"
        end
      end
    end
  end
end
