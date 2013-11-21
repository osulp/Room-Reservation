class Admin::RoomsController < AdminController
  respond_to :html, :json

  def index
    @rooms = Room.order(:floor, :name)
    respond_with @rooms
  end

  def new
    @room = Room.new
    respond_with @room
  end

  def edit
    @room = Room.find(params[:id])
    respond_with @room
  end

  def create
    @room = Room.new(room_params)
    flash[:success] = 'Room added' if @room.save
    respond_with @room, :location => admin_rooms_path
  end

  def update
    @room = Room.find(params[:id])
    flash[:success] = 'Room updated' if @room.update(room_params)
    respond_with @room, :location => admin_rooms_path
  end

  def destroy
    @room = Room.find(params[:id])
    flash[:success] = 'Room deleted' if @room.destroy
    respond_with(@role, :location => admin_rooms_path)
  end

  private

  def room_params
    params.require(:room).permit(:name, :floor, {:filter_ids => []})
  end
end
