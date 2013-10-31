class AdminController < ApplicationController
  before_filter :require_admin
  before_filter :init_admin_sidebar
  layout 'admin'
  respond_to :html

  def init_admin_sidebar
    @sidebar_items = {
      'settings' => { :name => 'Settings', :icon => 'fa-cogs'},
      'users' => { :name => 'Users', :icon => 'fa-user'},
      'rooms' => { :name => 'Rooms', :icon => 'fa-building'},
      'keycards' => { :name => 'Keycards', :icon => 'fa-key'}
    }

  end

  private

  def require_admin
    render :status => :unauthorized, :text => 'Only admin can access' unless current_user.admin?
  end
end
