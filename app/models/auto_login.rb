class AutoLogin < ActiveRecord::Base
  validates :username, :presence => true
  has_many :ip_addresses
end
