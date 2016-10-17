class Setting < ApplicationRecord
  has_paper_trail
  # Valid setting keys
  @setting_config ||= (YAML.load_file(Rails.root.join("config","settings.yml")) || {})
  VALID_KEYS = @setting_config.keys
  NUMERIC_KEYS = @setting_config.select{|x,y| y && y.has_key?("tag_attributes") && y["tag_attributes"]["type"] == "number"}.keys
  include DruthersPatch
  serialize :value

  # Define all the druthers getters/setters
  def_druthers(*self.const_get(:VALID_KEYS))

  # Define setting defaults.
  @setting_config.each do |key, value|
    if value && value["default"]
      define_singleton_method("default_#{key}") do
        value["default"]
      end
    end
  end

  # Define numerical validations.
  self.const_get(:NUMERIC_KEYS).each do |key|
    define_method("validate_#{key}") do
      numerical_validation
    end
  end

  def self.druthers_cache
    Rails.cache
  end

  def self.setting_config
    @setting_config
  end

  # @return [String] Friendly name of this asset (looked up in locale)
  def friendly_name
    ret = I18n.t("settings.#{key}", default: '')
    return key.to_s if ret == ''
    ret
  end
end
