class Admin::SettingsController < AdminController
  respond_to :html, :json

  def index
    @settings = Hash[scoped_collection.decorate.group_by(&:category).sort_by{|key, value| key}]
    miscellaneous = {"Miscellaneous Settings" => @settings.delete("Miscellaneous Settings")}
    @settings = miscellaneous.merge(@settings)
    respond_with(@settings)
  end

  def update
    @setting = Setting.find(params[:id])
    if @setting
      update_value = Setting.method("#{@setting.key}=")
      begin
        value = params[:setting][:value]
        if value.kind_of?(Hash)
          d = @setting.decorate
          d.immune_keys.each do |key|
            value[key] ||= @setting.value[key]
          end
        end
        update_value.call value
        flash[:success] = 'Settings successfully saved'
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = e.message
      end
    else
      flash[:error] = 'Unable to find requested setting'
    end
    redirect_to admin_settings_path
  end

  private

  def scoped_collection
    # Force copies of all the settings into the database, if we have to.
    Setting.valid_keys.each do |k|
      Setting.where(key: k).first_or_create(value: Setting.send(k))
    end

    Setting.all.order(:key)
  end
end
