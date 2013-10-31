require 'spec_helper'

describe Admin::UsersController do
  it_behaves_like 'admin_panel'
  let(:user) {nil}
  let(:banner_record) {nil}
  let(:build_role) {nil}
  before(:each) do
    RubyCAS::Filter.fake("fakeuser")
    RubyCAS::Filter.filter(self)
    build_role
    banner_record
  end

  context 'and is admin' do
    let(:build_role) {create(:role, :role => :admin, :onid  => "fakeuser")}
    describe "GET 'index'" do
      it "returns http success" do
        get 'index'
        response.should be_success
      end
    end

    describe "GET 'new'" do
      it "returns http success" do
        get 'new'
        response.should be_success
      end
    end
  end

end
