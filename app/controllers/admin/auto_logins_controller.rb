class Admin::AutoLoginsController < AdminController
  def index
    @auto_logins = AutoLogin.all
  end

  def new
    @auto_login = AutoLogin.new
    @auto_login.ip_addresses.build
  end

  def create
    @auto_login = AutoLogin.new(auto_login_params)
    if @auto_login.save
      flash[:success] = 'Successfully Created Auto Login'
      redirect_to admin_auto_logins_path
    else
      render :action => 'new'
    end
  end

  def edit
    @auto_login = AutoLogin.find(params[:id])
  end

  # TODO: Figure out why respond_with isn't rendering new correctly.
  def update
    @auto_login = AutoLogin.find(params[:id])
    if @auto_login.update(auto_login_params)
      flash[:success] = 'Auto Login Updated'
      redirect_to admin_auto_logins_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @auto_login = AutoLogin.find(params[:id])
    flash[:success] = 'Auto Login deleted' if @auto_login.destroy
    respond_with(@auto_login, :location => admin_auto_logins_path)
  end

  private

  def build_errors
    flash.now[:error] = @auto_login.errors.full_messages
    #flash.now[:error] |= @auto_login.ip_addresses.map{|x| x.errors.full_messages}.flatten
    flash.now[:error] = flash[:error].to_sentence
  end

  def auto_login_params
    params.require(:auto_login).permit(:username, :ip_addresses_attributes => [:_destroy, :id, :ip_address])
  end
end
