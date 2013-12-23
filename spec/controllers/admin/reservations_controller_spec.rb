require 'spec_helper'

describe Admin::ReservationsController do
  # Can't use shared routes because user_id is required. May be useful to add parameters for this situation to
  # shared admin examples.
  describe "authorization" do
    let(:user) {build(:user)}
    let(:banner_record) {nil}
    context 'when user is not logged in' do
      it "should redirect for authorization" do
        get :index, :user_id => user.onid
        expect(response.status).to eq 302 # Redirect
        expect(response).to redirect_to(login_path(:source => request.original_fullpath))
      end
    end

    context "when a user is logged in" do
      before(:each) do
        RubyCAS::Filter.fake(user.onid)
        RubyCAS::Filter.filter(self)
      end
      context "but not an admin" do
        it "should be unauthorized" do
          get :index, :user_id => user.onid
          expect(response.status).to eq 401 # Unauthorized
        end
      end

      context 'and is admin' do
        let(:user) {build(:user, :admin)}
        it "returns http success" do
          get 'index', :user_id => user.onid
          response.should be_success
        end
      end
    end
  end
end
