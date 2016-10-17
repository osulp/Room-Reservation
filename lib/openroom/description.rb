class Openroom::Description < ApplicationRecord
  establish_connection :"openroom_#{Rails.env}"
  self.table_name = "reservationoptions"
  default_scope {where(:optionname => "description")}
end
