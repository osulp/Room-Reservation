class AutoLogin < ApplicationRecord
  has_paper_trail
  validates :username, :presence => true
  has_many :ip_addresses, :dependent => :destroy
  accepts_nested_attributes_for :ip_addresses, allow_destroy: true, reject_if: proc { |ip| ip[:ip_address].blank? }
end
