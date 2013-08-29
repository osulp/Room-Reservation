class Reservation < ActiveRecord::Base
  belongs_to :room
  attr_accessible :description, :end_time, :reserver_onid, :start_time, :user_onid, :room
  validates :end_time, :start_time, :reserver_onid, :user_onid, presence: true

  after_save :expire_presenter
  after_destroy :expire_presenter

  def duration
    self.end_time - self.start_time
  end

  protected

  def expire_presenter
    start_date = self.start_time.to_date
    end_date = (self.end_time-1.second).to_date
    start_date.upto(end_date) do |date|
      time = Time.zone.parse(date.to_s)
      CalendarPresenter.expire_time(time, time.tomorrow.midnight)
    end
  end

end
