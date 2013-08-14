require 'spec_helper'

describe User do
  describe "#current" do
    context "when a user isn't logged in" do
      it "should return nil" do
        User.current.should == nil
      end
    end
    context "when a user is logged in" do

    end
  end
end