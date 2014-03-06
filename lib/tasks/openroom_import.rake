namespace :roomreservation do
  desc "Import old room reservation information"
  task :openroom_import => :environment do
    Reservation.transaction do
      # Import rooms first.
      puts "Importing Rooms"
      Openroom::Room.all.each do |room|
        converted_room = room.converted
        converted_room.save!
        print "."
      end
      # Import reservations
      puts ''
      puts "Importing Reservations"
      Openroom::Reservation.where("end >= ? AND username != '' AND cleaning != 1", Time.current.strftime('%Y-%m-%d')).each do |reservation|
        converted_reservation = reservation.converted
        converted_reservation.save!
        print "!"
      end
      puts ''
    end
  end
end
