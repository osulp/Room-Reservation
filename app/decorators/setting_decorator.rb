class SettingDecorator < Draper::Decorator
  delegate_all

  def field_configuration
    configuration["tag_attributes"] || {}
  end

  def configuration
    self.class.setting_config[key] || {}
  end

  def category
    configuration["category"] || "Miscellaneous Settings"
  end

  def field_type
    configuration["field_type"] || "text_field"
  end

end
