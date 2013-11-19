class Admin::FiltersController < AdminController
  respond_to :html, :json

  def index
    @filters = Filter.all
    respond_with @filters
  end

  def new
    @filter = Filter.new
    respond_with @filter
  end

  def edit
    @filter = Filter.find(params[:id])
    respond_with @filter
  end

  def create
    @filter = Filter.new(filter_params)
    flash[:success] = 'Room filter added' if @filter.save
    respond_with @filter, :location => admin_filters_path
  end

  def update
    @filter = Filter.find(params[:id])
    flash[:success] = 'Room filter updated' if @filter.update(filter_params)
    respond_with @filter, :location => admin_filters_path
  end

  def destroy
    @filter = Filter.find(params[:id])
    flash[:success] = 'Room filter deleted' if @filter.destroy
    respond_with(@role, :location => admin_filters_path)
  end

  private

  def filter_params
    params.require(:filter).permit(:name)
  end
end
