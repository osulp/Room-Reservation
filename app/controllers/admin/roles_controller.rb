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
    @role = Role.new(role_params)
    flash[:success] = 'Role added' if @role.save
    respond_with(@role, :location => admin_roles_path)
  end

  def update
    @role = Role.find(params[:id])
    if @role.onid == current_user.onid
      flash[:error] = 'Cannot update yourself'
    else
      flash[:success] = 'Role updated' if @role.update(role_params)
    end
    respond_with(@role, :location => admin_roles_path)
  end

  def destroy
    @role = Role.find(params[:id])
    if @role.onid == current_user.onid
      flash[:error] = 'Cannot delete yourself'
    else
      flash[:success] = 'Role deleted' if @role.destroy
    end
    respond_with(@role, :location => admin_roles_path)
  end

  private

  def role_params
    params.require(:role).permit(:role, :onid)
  end
end
