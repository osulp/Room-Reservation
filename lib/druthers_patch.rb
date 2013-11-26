module DruthersPatch
  extend ActiveSupport::Concern
  included do
    def_druthers(*self.const_get(:VALID_KEYS))

    self.const_get(:NUMERIC_KEYS).each do |key|
      define_method("validate_#{key}") do
        numerical_validation
      end
    end

    private

    def numerical_validation
      validator = ActiveModel::Validations::NumericalityValidator.new(:attributes => [:value], :only_integer => true, :greater_than_or_equal_to => 0)
      validator.validate(self)
    end
  end
  module ClassMethods
    def valid_keys
      self.const_get(:VALID_KEYS)
    end

    def set_druther(key, value)
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
    def get_druther(key)
      druthers_cache.fetch("#{self}/#{key}") do
        val = where(key: key).pluck(:value).to_a
        val.present? ? val.first : send_druthers_event(:default, key)
      end
    end
  end
end