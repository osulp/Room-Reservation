class Setting < ActiveRecord::Base
  serialize :value
  # Valid setting keys
  VALID_KEYS = [:max_concurrent_reservations]

  def self.valid_keys
    VALID_KEYS
  end

  def_druthers(*VALID_KEYS)

  def self.default_max_concurrent_reservations
    0
  end

  def validate_max_concurrent_reservations
    validator = ActiveModel::Validations::NumericalityValidator.new(:attributes => [:value], :only_integer => true, :greater_than_or_equal_to => 0)
    validator.validate(self)
  end

  # @return [String] Friendly name of this asset (looked up in locale)
  def friendly_name
    ret = I18n.t("settings.#{key}", default: '')
    return key.to_s if ret == ''
    ret
  end
end
