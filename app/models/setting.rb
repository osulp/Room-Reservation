class Setting < ActiveRecord::Base
  serialize :value
  # Valid setting keys
  VALID_KEYS = [:max_concurrent_reservations, :announcement_header_message, :day_limit]
  NUMERIC_KEYS = [:max_concurrent_reservations, :day_limit]

  def self.valid_keys
    VALID_KEYS
  end

  def self.druthers_cache
    Rails.cache
  end

  def self.set_druther(key, value)
    obj = where(key: key).first_or_initialize
    if obj.respond_to? :update!
      # Rails 4.x:
      obj.update!(value: value)
    else
      # Rails 3.x:
      obj.update_attributes!(value: value)
    end
    # Only update the cache if the update! succeeded:
    druthers_cache.write("#{self}/#{key}", value)
    obj
  end
  def self.get_druther(key)
    druthers_cache.fetch("#{self}/#{key}") do
      val = where(key: key).pluck(:value).to_a
      val.present? ? val.first : send_druthers_event(:default, key)
    end
  end

  def_druthers(*VALID_KEYS)

  def self.default_max_concurrent_reservations
    0
  end

  def self.default_announcement_header_message
    ''
  end

  def self.default_day_limit
    0
  end

  NUMERIC_KEYS.each do |key|
    define_method("validate_#{key}") do
      numerical_validation
    end
  end

  # @return [String] Friendly name of this asset (looked up in locale)
  def friendly_name
    ret = I18n.t("settings.#{key}", default: '')
    return key.to_s if ret == ''
    ret
  end

  private

  def numerical_validation
    validator = ActiveModel::Validations::NumericalityValidator.new(:attributes => [:value], :only_integer => true, :greater_than_or_equal_to => 0)
    validator.validate(self)
  end
end
