require 'spec_helper'

describe Room do
  subject { Room.create! :name => 'TestRoom', :floor => 4 }

  describe "validations" do
    it {should validate_presence_of(:name)}
    it {should validate_presence_of(:floor)}
    it {should validate_numericality_of(:floor).only_integer}
    it {should have_many :room_filters}
    it {should have_many(:filters).through(:room_filters)}
    it {should have_many :cleaning_record_rooms}
    it {should have_many(:cleaning_records).through(:cleaning_record_rooms)}
    it {should have_many(:room_hour_records)}
    it {should have_many(:room_hours).through(:room_hour_records)}
  end

end
