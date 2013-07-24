require 'spec_helper'

describe RoomFilter do
  describe "validations" do
    it {should validate_presence_of(:room)}
    it {should validate_presence_of(:filter)}
    it {should belong_to(:room)}
    it {should belong_to(:filter)}
  end
end
