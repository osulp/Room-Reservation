class Admin::SettingsController < AdminController
  respond_to :html, :json

  def index
    @settings = scoped_collection
    respond_with(@settings)
  end

  def update
    @setting = Setting.find(params[:id])
    if @setting.update(setting_params)
      flash[:notice] = 'Settings successfully saved'
    else
      flash[:error] = @setting.errors.full_messages.join("<br>")
    end
    redirect_to admin_settings_path
  end

  private

  def scoped_collection
    # Force copies of all the settings into the database, if we have to.
    Setting.valid_keys.each do |k|
      Setting.where(key: k).first_or_create(value: Setting.send(k))
    end

    Setting.all
  end

  def setting_params
    params.require(:setting).permit(:value)
  end
end
