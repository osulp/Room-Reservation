class Admin::PatronModeController < AdminController
  respond_to :json

  def enable
    status = params[:enable] || false
    session[:patron_mode] = (status.to_s == "true")
    render :json => {:success => true}
  end

  def status
    render :json => ({:status => !!session[:patron_mode]})
  end
end
