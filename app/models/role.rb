class Role < ApplicationRecord
  has_paper_trail
  validates :role, :onid, :presence => true
end
