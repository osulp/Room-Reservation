class Admin::RoomHoursController < AdminController
  before_filter :find_room_hour, :only => [:destroy, :show, :edit, :update]

  def index
    @room_hours = RoomHour.all.decorate
  end

  def destroy
    flash[:success] = 'Room hour deleted' if @room_hour.destroy
    @room_hour = @room_hour.decorate
    respond_with(@room_hour, :location => admin_room_hours_path)
  end

  private

  def find_room_hour
    @room_hour = RoomHour.find(params[:id])
  end
end
