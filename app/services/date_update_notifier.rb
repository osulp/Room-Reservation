class DateUpdateNotifier

  def notify_update(date,presenter=nil)
    begin
      @presenter = presenter
      data = date_html(date)
      send_message("/messages/date/#{date.year}-#{date.month}-#{date.day}", data)
    rescue Errno::ECONNREFUSED
      Rails.logger.warn "FAYE Server at #{faye_path} unresponsive."
    end
  end

  def date_html(date)
    c = ApplicationController.new
    presenter = @presenter || CalendarPresenter.cached(Time.zone.parse(date.to_s), Time.zone.parse((date+1.day).to_s))
    c.instance_variable_set(:@presenter, presenter)
    c.render_to_string(:partial => "home/room_list")
  end

  def send_message(channel,data=nil)
    data ||= "Updated"
    message = {:channel => channel, :data => data, :ext => {:auth_token => auth_token}}
    Net::HTTP.post_form(faye_server, :message => message.to_json)
  end

  def auth_token
    APP_CONFIG["push"]["token"]
  end

  def client
    @client
  end

  def faye_server
    @faye_server ||= URI.parse(faye_path)
  end

  def faye_path
    APP_CONFIG['push']['server']
  end
end