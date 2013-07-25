require 'spec_helper'

describe Room do

  describe "validations" do
    it {should validate_presence_of(:name)}
    it {should validate_presence_of(:floor)}
    it {should validate_numericality_of(:floor).only_integer}
    it {should have_many :room_filters}
    it {should have_many(:filters).through(:room_filters)}
  end

end
