class ReservationMailer < ActionMailer::Base
  def reservation_email(reservation, user)
    @user = user
    @reservation = reservation
    @footer = Setting.reservation_email
    mail(:to => @user.email, :from => from_email, :reply_to => from_email, :subject => reservation_subject)
  end

  def update_email(reservation, user)
    @user = user
    @reservation = reservation
    @previous = @reservation.previous_version
    @footer = Setting.update_email
    mail(:to => @user.email, :from => from_email, :reply_to => from_email, :subject => update_subject)
  end

  def cancellation_email(reservation, user)
    @user = user
    @reservation = reservation
    @footer = Setting.cancellation_email
    mail(:to => @user.email, :from => from_email, :reply_to => from_email, :subject => cancellation_subject)
  end

  private

  def reservation_subject
    "Study Room Reservations Reservation"
  end

  def cancellation_subject
    "Study Room Reservations Cancellation"
  end

  def update_subject
    "Study Room Reservation Updated"
  end

  def from_email
    "#{Setting.from_name} <#{Setting.from_address}>"
  end

end