require 'spec_helper'

describe User do
  subject {build(:user, :onid => "bla")}
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
  describe "#roles" do
    context "when they have no roles" do
      it "should return a blank array" do
        expect(subject.roles).to eq []
      end
    end
    context "when they have roles" do
      subject {build(:user, :admin, :onid => "bla")}
      it "should return all roles applicable to that user" do
        expect(subject.roles.size).to eq 1
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
      subject {build(:user, :admin)}
      it "should return true" do
        expect(subject.admin?).to be_true
      end
    end
  end
  describe ".reservations" do
    context "when the user has no reservations" do
      it "should return a blank array" do
        expect(subject.reservations).to eq []
      end
    end
    context "when the user has reservations" do
      before(:each) do
        @reservation = create(:reservation, :user_onid => subject.onid)
        create(:reservation)
      end
      it "should return the reservation" do
        expect(subject.reservations).to eq [@reservation]
      end
    end
  end
  describe ".reservations.active" do
    context "when the user has reservations" do
      before(:each) do
        @reservation = create(:reservation, :user_onid => subject.onid)
        @reservation_2 = create(:reservation, :user_onid => subject.onid)
      end
      context "but none are checked out" do
        it "should return an empty array" do
          expect(subject.reservations.active).to eq []
        end
      end
      context "and they are checked out" do
        before(:each) do
          create(:key_card, :room => @reservation.room, :reservation => @reservation)
        end
        it "should return the checked out reservations" do
          expect(subject.reservations.active).to eq [@reservation]
        end
      end
    end
  end
end