class AutoLogin < ActiveRecord::Base
  has_paper_trail
  validates :username, :presence => true
  has_many :ip_addresses
end
