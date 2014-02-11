class Admin::LogsController < AdminController
  def index
    @presenter = LogsPresenter.new(self,params)
    #@reservations = AdminReservationsDecorator.new(filtered_reservations.page(params[:page]).per(per_page))
  end
end
