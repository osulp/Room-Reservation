require 'spec_helper'

describe AdminController do
  it_behaves_like 'admin_panel'
  context "when logged in as an admin" do
    let(:user) {build(:user, :admin)}
    before(:each) do
      RubyCAS::Filter.fake(user.onid)
      RubyCAS::Filter.filter(self)
    end
    describe 'index' do
      it "should work" do
        get :index
        expect(response).to be_success
      end
    end
  end
end
