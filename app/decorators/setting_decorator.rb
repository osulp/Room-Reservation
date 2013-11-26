class SettingDecorator < Draper::Decorator
  delegate_all

  def field_configuration
    self.class.setting_config[key] || {}
  end

end
