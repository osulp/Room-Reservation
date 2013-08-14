require 'spec_helper'

describe User do
  describe "initialization" do
    context "when passed just an onid" do
      subject {User.new("bla")}
      it "should create a user object" do
        expect(subject).to be_kind_of(User)
      end
      it "should respond to .onid" do
        expect(subject.onid).to eq "bla"
      end
    end
    context "when passed an onid and extra parameters" do
      subject {User.new("bla", :email => 'trey.trey@test.org')}
      it "should respond to .onid" do
        expect(subject.onid).to eq "bla"
      end
      it "should respond to passed parameters" do
        expect(subject.email).to eq "trey.trey@test.org"
      end
    end
  end
end