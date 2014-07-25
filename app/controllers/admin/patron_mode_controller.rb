class Admin::PatronModeController < AdminController
  respond_to :json

  def enable
    status = params[:enable] || false
    session[:patron_mode_disabled] = !(status.to_s == "true")
    render :json => {:success => true}
  end

  def status
    render :json => ({:status => patron_mode?})
  end
end
