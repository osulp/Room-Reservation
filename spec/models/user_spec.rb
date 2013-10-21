require 'spec_helper'

describe User do
  subject {User.new("bla")}
  describe "initialization" do
    context "when passed just an onid" do
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
  describe ".banner_record" do
    context "when there is no banner record for that ONID" do
      it "should return nil" do
        expect(subject.banner_record).to be_nil
      end
    end
    context "when there is a matching banner record" do
      before(:each) do
        create(:banner_record, :onid => "bla")
      end
      it "should return the matching banner record" do
        expect(subject.banner_record).to be_kind_of(BannerRecord)
        expect(subject.banner_record.onid).to eq "bla"
      end
      it "should be memoized" do
        BannerRecord.should_receive(:where).once.and_call_original
        subject.banner_record
        subject.banner_record
      end
    end
  end
  describe "#admin?" do
    context "when they are not an admin" do
      it "should return false" do
        expect(subject.admin?).to be_false
      end
    end
    context "when they are an admin" do
      before(:each) do
        create(:role, :onid => subject.onid, :role => "admin")
      end
      it "should return true" do
        expect(subject.admin?).to be_true
      end
    end
  end
end