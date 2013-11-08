require 'spec_helper'

describe RoomFilter do
  describe "validations" do
    it {should belong_to(:room)}
    it {should belong_to(:filter)}
  end
end
