class Reserver
  include ActiveModel::Model
  include ActionView::Helpers::TextHelper
  # Callbacks
  define_model_callbacks :reservation_save
  # Keycard Include
  include Keycards::ReserverModule
  # Validations
  include Reserver::Validations
  # Reservation Validations
  include Reservation::Validations

  delegate :reserver, :user, :reserver_onid, :user_onid, :room_id, :room, :start_time, :end_time, :description, :key_card, :decorate, :user_banner_record, :to => :reservation
  delegate :start_time=, :end_time=, :room=, :reserver=, :user=, :reserver_onid=, :user_onid=, :to => :reservation
  attr_accessor :key_card_key
  attr_reader :reservation

  delegate :as_json, :read_attribute_for_serialization, :to => :reservation
  after_reservation_save :send_email
  before_reservation_save :reset_truncated_at


  def self.reflect_on_association(association)
    Reservation.reflect_on_association(association)
  end

  def self.model_name
    Reservation.model_name
  end

  def initialize(attributes = {},options={})
    @options = options
    if attributes.kind_of?(Reservation)
      @reservation = attributes
      return
    end
    self.key_card_key = attributes.delete(:key_card_key)
    @reservation ||= Reservation.new
    @reservation.attributes = attributes
  end

  def save
    return false unless valid?
    @reservation ||= Reservation.new

    run_callbacks :reservation_save do
      @reservation.save
    end
  end

  def persisted?
    reservation.persisted?
  end

  def reservation
    @reservation || Reservation.new
  end

  private

  def send_email
    return if @options[:ignore_email]
    unless user.email.blank?
      begin
        ReservationMailer.delay.send(email_method, reservation, user.decorate)
      rescue Redis::CannotConnectError
        return
      end
    end
  end

  def email_method
    @email_method ||= begin
      return @options[:email_method] unless @options[:email_method].blank?
      if reservation.versions.size > 1
        :update_email
      else
        :reservation_email
      end
    end
  end

  def day_limit
    (Setting.day_limit || 0).to_i
  end



  def append_reservation_errors
    return if !reservation
    unless reservation.valid?
      reservation.errors.full_messages.each do |msg|
        self.errors.add(:base, msg)
      end
    end
  end

  def reset_truncated_at
    if reservation.changed? && !reservation.truncated_at_changed?
      reservation.truncated_at = nil
    end
  end


end
