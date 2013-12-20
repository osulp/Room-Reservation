class BannerRecord < ActiveRecord::Base
  establish_connection "banner_#{Rails.env}"
  self.table_name = "BannerLookup"

  validates :onid, :presence => true

  def self.find_by_osu_id(id)
    hash = IdHash.create(id)
    self.where(:idHash => hash).first!
  end

  def self.soft_find_by_osu_id(id)
    hash = IdHash.create(id)
    self.where(:idHash => hash).first
  end

  def osu_id=(value)
    self.idHash = IdHash.create(value).to_s
  end

  def osu_id
    IdHash.new(self.idHash)
  end
end