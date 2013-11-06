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
    respond_with(@role, :location => admin_roles_path)
  end

  def update
    @role = Role.find(params[:id])
    if @role.onid == current_user.onid
      flash[:notice] = 'Cannot update yourself'
    else
      flash[:notice] = 'Role updated' if @role.update(params[:role])
    end
    respond_with(@role, :location => admin_roles_path)
  end

  def destroy
    @role = Role.find(params[:id])
    if @role.onid == current_user.onid
      flash[:notice] = 'Cannot delete yourself'
    else
      @role.destroy
    end
    respond_with(@role, :location => admin_roles_path)
  end
end
