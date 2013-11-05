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
    let(:build_role) {create(:role, :id => 1, :role => :admin, :onid  => "fakeuser")}
    describe "GET 'index'" do
      it { get :index; response.should be_success }
    end

    describe "GET 'new'" do
      it { get :new; response.should be_success }
    end

    describe "POST 'promote'" do
      it { post :promote, id: 1; response.should redirect_to :action => :index }
    end

    describe "POST 'demote'" do
      it { post :demote, id: 1; response.should redirect_to :action => :index }
    end

  end

end
