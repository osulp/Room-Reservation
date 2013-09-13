require 'spec_helper'

describe Reservation do
  describe "validations" do
     it {should validate_presence_of(:user_onid)}
     it {should validate_presence_of(:reserver_onid)}
     it {should validate_presence_of(:start_time)}
     it {should validate_presence_of(:end_time)}
     it {should validate_presence_of(:room)}
     it {should belong_to(:room)}
  end
end
