class HomeController < ApplicationController
  before_filter RubyCAS::GatewayFilter, :only => :index
  layout Proc.new { |controller| controller.request.xhr? ? nil : "application" }
  def index
    calendar = CalendarManager.new(cookies)
    @presenter = CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight)
  end

  def day
    Rack::MiniProfiler.step "Calendar Manager" do
      date = params[:date].split("-")
      raise "Invalid date given" if date.length != 3
      calendar_hash = {:year => date[0], :month => date[1], :day => date[2]}
      calendar = CalendarManager.new(calendar_hash)
      Rack::MiniProfiler.step "Presenter Generation" do
        @presenter = CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight)
        Rack::MiniProfiler.step "Cache Key Generation" do
          puts "Cache Key: #{@presenter.cache_key}"
        end
      end
    end
    render :partial => 'room_list', :locals => {:floors => @floors}
  end
end