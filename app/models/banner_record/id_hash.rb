class BannerRecord::IdHash < String
  def self.create(id)
    self.new(self.encrypt_id(id))
  end

  def ==(other_value)
    super(self.class.encrypt_id(other_value))
  end

  private

  def self.encrypt_id(id)
    id.to_s.crypt("$6$#{self.salt}").split('$').last
  end

  def self.salt
    ENV["BANNER_SALT"]
  end
end