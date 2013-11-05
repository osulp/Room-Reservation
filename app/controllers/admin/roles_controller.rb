class Admin::RolesController < AdminController
  respond_to :html, :json

  def index
    @roles = Role.all
    respond_with @roles
  end

  def new
    @role = Role.new
    @role.role = 'staff'
    respond_with @role
  end

  def create
    @role = Role.new(params[:role])
    flash[:notice] = 'Role added' if @role.save
    redirect_to :action => :index
  end

  def update
    @role = Role.find(params[:id])
    if @role.onid == current_user.onid
      flash[:notice] = 'Cannot update yourself'
    else
      flash[:notice] = 'Role updated' if @role.update(params[:role])
    end
    redirect_to :action => :index
  end

  def destroy
    @role = Role.find(params[:id])
    if @role.onid == current_user.onid
      flash[:notice] = 'Cannot delete yourself'
    else
      @role.destroy
    end
    redirect_to :action => :index
  end
end
