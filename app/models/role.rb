class Role < ActiveRecord::Base
  has_paper_trail
  validates :role, :onid, :presence => true
end
