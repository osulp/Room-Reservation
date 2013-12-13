class Admin::KeyCardsController < AdminController
  respond_to :html, :json
  skip_before_filter :require_admin, :only => :search
  before_filter :require_staff, :only => :search
  layout false, :only => :search

  def index
    @keycards = KeyCard.includes(:room).order('rooms.name')
    respond_with @keycards
  end

  def new
    @keycard = KeyCard.new
    respond_with @keycard
  end

  def edit
    @keycard = KeyCard.find(params[:id])
    respond_with @keycard
  end

  def create
    @keycard = KeyCard.new(keycard_params)
    flash[:success] = 'Key Card added' if @keycard.save
    respond_with @keycard, :location => admin_key_cards_path
  end

  def update
    @keycard = KeyCard.find(params[:id])
    flash[:success] = 'Key Card updated' if @keycard.update(keycard_params)
    respond_with @keycard, :location => admin_key_cards_path
  end

  def destroy
    @keycard = KeyCard.find(params[:id])
    flash[:success] = 'Key Card deleted' if @keycard.destroy
    respond_with(@role, :location => admin_key_cards_path)
  end

  def search
    @keycard = KeyCard.where(:key => params[:key]).first!.decorate
    if @keycard.reservation
      render "checkin"
    else
      render "checkout"
    end
  end

  private

  def keycard_params
    params.require(:key_card).permit(:key, :room_id)
  end
end
