class ReservationMailer < ActionMailer::Base
  def reservation_email(reservation, user)
    @user = user
    @reservation = reservation
    @footer = Setting.reservation_email
    mail(:to => @user.banner_record.email, :from => from_email, :reply_to => from_email, :subject => reservation_subject)
  end

  private

  def reservation_subject
    "Study Room Reservations Reservation"
  end

  def from_email
    "#{Setting.from_name} <#{Setting.from_address}>"
  end

end