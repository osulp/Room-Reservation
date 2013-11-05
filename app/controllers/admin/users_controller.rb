class Admin::UsersController < AdminController
  respond_to :html, :json

  ADMIN_ROLE = 'admin'
  STAFF_ROLE = 'staff'
  NONE_ROLE = 'none'

  def index
    @roles = Role.all
    respond_with @roles
  end

  def new
    @role = Role.new
    respond_with @role
  end

  def create
    @role = Role.new(params[:role])
    @role.role = NONE_ROLE
    flash[:notice] = 'User added' if @role.save
    respond_with @role
  end

  def edit
    @role = Role.find(params[:id])
    respond_with @role
  end

  def update
    @role = Role.find(params[:id])
    flash[:notice] = 'Record updated' if @role.update(params[:role])
    respond_with @role
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    respond_with @role
  end

  def promote
    redirect_to action: :index
    @role = Role.find(params[:id])

    return if ADMIN_ROLE == @role.role
    @role.role = ADMIN_ROLE if STAFF_ROLE == @role.role
    @role.role = STAFF_ROLE if NONE_ROLE == @role.role
    flash[:notice] = 'User promoted' if @role.save
  end

  def demote
    redirect_to action: :index
    @role = Role.find(params[:id])

    flash[:notice] = 'No self demotion' and return if @role.onid == current_user.onid

    return if NONE_ROLE == @role.role
    @role.role = NONE_ROLE if STAFF_ROLE == @role.role
    @role.role = STAFF_ROLE if ADMIN_ROLE == @role.role
    flash[:notice] = 'User demoted' if @role.save
  end

end
