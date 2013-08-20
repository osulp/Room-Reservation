class SpecialHour < ActiveRecord::Base
  establish_connection "drupal_#{Rails.env}"
  self.table_name = "special_hours"
end