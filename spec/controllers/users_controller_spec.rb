require 'spec_helper'

describe UsersController do
  describe "#show" do
    let(:user) {nil}
    let(:banner_record) {nil}
    context "when a user is not logged in" do
      before(:each) do
        get :show, :format => :json, :id => "931590000"
      end
      it "should be unauthorized" do
        expect(response.status).to eq 401 # Unauthorized
      end
    end
    context "when a user is logged in" do
      let(:user) {build(:user)}
      before(:each) do
        RubyCAS::Filter.fake(user.onid)
        RubyCAS::Filter.filter(self)
        banner_record
      end
      context "and they are not an admin" do
        it "should be unauthorized" do
          get :show, :format => :json, :id => "931590000"
          expect(response.status).to eq 401 # Unauthorized
        end
      end
      context "and they are staff" do
        let(:user) {build(:user, :staff)}
        context "and the user exists" do
          let(:banner_record) {create(:banner_record, :onid => "fakeuser", :osu_id => "931590000")}
          context "and they search by ID" do
            before(:each) do
              get :show, :format => :json, :id => "931590000"
            end
            it "should return the user's information" do
              expect(JSON.parse(response.body)["onid"]).to eq "fakeuser"
            end
          end
          context "and they swipe a card" do
            before(:each) do
              get :show, :format => :json, :id => "11931590000"
            end
            it "should return the user's information" do
              expect(JSON.parse(response.body)["onid"]).to eq "fakeuser"
            end
          end
          context "and they search by the banner record's ONID" do
            before do
              get :show, :format => :json, :id => "fakeuser"
            end
            it "should return the user's information" do
              expect(JSON.parse(response.body)["onid"]).to eq "fakeuser"
            end
          end
        end
        context "and the user doesn't exist" do
          it "should raise ActiveRecord::RecordNotFound" do
            expect{get :show, :format => :json, :id => "931590000"}.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
