class Admin::LogsController < AdminController
  def index
    @presenter = LogsPresenter.new(self,params)
  end
end
