class Setting < ActiveRecord::Base
  # Valid setting keys
  VALID_KEYS = [:max_concurrent_reservations, :announcement_header_message, :day_limit, :reservation_email]
  NUMERIC_KEYS = [:max_concurrent_reservations, :day_limit]
  include DruthersPatch
  serialize :value

  def self.druthers_cache
    Rails.cache
  end

  def self.default_max_concurrent_reservations
    0
  end

  def self.default_announcement_header_message
    ''
  end

  def self.default_reservation_email
    ''
  end

  def self.setting_config
    @setting_config ||= (YAML.load_file(Rails.root.join("config","settings.yml")) || {})
  end

  def self.default_day_limit
    0
  end

  # @return [String] Friendly name of this asset (looked up in locale)
  def friendly_name
    ret = I18n.t("settings.#{key}", default: '')
    return key.to_s if ret == ''
    ret
  end
end
