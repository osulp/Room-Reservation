class AdminController < ApplicationController
  before_filter :require_login
  before_filter :require_admin
  layout 'admin'
  respond_to :html

  def index
  end

  protected

  private

  def require_admin
    render :status => :unauthorized, :text => 'Only admin can access' unless current_user.admin?
  end

end
