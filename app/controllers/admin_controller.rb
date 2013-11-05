class AdminController < ApplicationController
  before_filter :require_admin
  layout 'admin'
  respond_to :html

  def index
  end

  protected

  def self.responder
    AdminResponder
  end

  private

  def require_admin
    render :status => :unauthorized, :text => 'Only admin can access' unless current_user.admin?
  end

end
