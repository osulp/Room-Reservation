require 'spec_helper'

describe Admin::KeyCardsController do
  it_behaves_like 'admin_panel'
  describe "#checkin" do
    let(:keycard) {create(:key_card)}
    let(:user) {build(:user, :admin)}
    before(:each) do
      RubyCAS::Filter.fake(user.onid)
      RubyCAS::Filter.filter(self)
    end
    context "when a keycard is given" do
      before(:each) do
        post :checkin, :key => keycard.key, :format => :json
      end
      context "with no reservation" do
        it "should return errors in JSON form" do
          expect(json_response).to have_key "errors"
        end
        it "should not a be a successful error code" do
          expect(response).not_to be_success
        end
      end
      context "with a reservation" do
        let(:keycard) {create(:key_card_checked_out)}
        it "should return the resulting keycard" do
          expect(json_response).to have_key("keycard")
        end
      end
    end
  end
  def json_response
    JSON.parse(response.body)
  end
end
