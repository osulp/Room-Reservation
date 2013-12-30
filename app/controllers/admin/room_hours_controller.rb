class Admin::RoomHoursController < AdminController
  before_filter :find_room_hour, :only => [:destroy, :show, :edit, :update]

  def index
    @room_hours = RoomHour.all.decorate
  end

  def new
    @room_hour = RoomHour.new(:start_date => Time.current.to_date, :end_date => Time.current.to_date).decorate
  end

  # TODO: Figure out why respond_with isn't rendering new correctly.
  def create
    @room_hour = RoomHour.new(room_hour_params)
    if @room_hour.save
      flash[:success] = 'Succesfully Created Room Hour'
      redirect_to admin_room_hours_path
    else
      build_errors
      @room_hour = @room_hour.decorate
      render :action => 'new'
    end
  end

  def edit
    @room_hour = @room_hour.decorate
    respond_with @room_hour
  end


  # TODO: Figure out why respond_with isn't rendering new correctly.
  def update
    if @room_hour.update(room_hour_params)
      flash[:success] = 'Room Hour Updated'
      redirect_to admin_room_hours_path
    else
      build_errors
      @room_hour = @room_hour.decorate
      render :action => 'edit'
    end
  end

  def destroy
    flash[:success] = 'Room hour deleted' if @room_hour.destroy
    @room_hour = @room_hour.decorate
    respond_with(@room_hour, :location => admin_room_hours_path)
  end

  private

  def build_errors
    flash[:error] = @room_hour.errors.full_messages
    flash[:error] |= @room_hour.rooms.map{|x| x.errors.full_messages}.flatten
    flash[:error] = flash[:error].to_sentence
  end

  def find_room_hour
    @room_hour = RoomHour.find(params[:id])
  end

  def room_hour_params
    params.require(:room_hour).permit(:start_date, :end_date, :start_time, :end_time,  {:room_ids => []})
  end
end
