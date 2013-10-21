class Role < ActiveRecord::Base
  validates :role, :onid, :presence => true
end
