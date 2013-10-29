class DateUpdateNotifier

  def notify_update(date)
    begin
      send_message("/messages/date/#{date.year}-#{date.month}-#{date.day}")
    rescue Errno::ECONNREFUSED
      Rails.logger.warn "FAYE Server at #{faye_path} unresponsive."
    end
  end

  def send_message(channel)
    message = {:channel => channel, :data => "Updated", :ext => {:auth_token => auth_token}}
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