class User < OpenStruct
  def initialize(name, extra_params={})
    extra_params ||= {}
    extra_params[:onid] = name
    super(extra_params)
  end

  def banner_record
    @banner_record ||= BannerRecord.where(:onid => self.onid).first
  end

  def reservations
    Reservation.where(:user_onid => onid)
  end
end
