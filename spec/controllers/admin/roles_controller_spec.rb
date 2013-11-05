require 'spec_helper'

describe Admin::RolesController do
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

  context 'is admin' do
    let(:banner_record) {create(:banner_record, :onid => "fakeuser", :osu_id => "931590000")}
    let(:build_role) {create(:role, :role => "admin", :onid  => "fakeuser")}
    describe "GET 'index'" do
      it 'assigns @roles' do
        roles = Role.all
        get :index
        expect(assigns(:roles)).to eq roles
      end
      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
        expect(response).to be_success
      end
    end

    describe "GET 'new'" do
      it 'renders the new template' do
        get :new
        expect(response).to render_template(:new)
        expect(response).to be_success
      end
    end

    describe "POST 'create'" do
      it 'creates new role' do
        expect {
          post :create, :role => {:role => 'foo', :onid => 'bar'}
        }.to change(Role, :count)
      end
      it 'redirects to index page' do
        post :create, :role =>  {:role => 'foo', :onid => 'bar'}
        expect(response).to redirect_to(:action => :index)
      end
    end

    describe "POST 'update'" do
      before :each do
        @role = create(:role, :role => 'admin', :onid => 'john')
        @me = Role.where(:onid => 'fakeuser').first
      end
      it 'updates the role' do
        post :update, :id => @role, :role => {:role => 'foo', :onid => 'john'}
        @role.reload
        expect(@role.role).to eq('foo')
      end
      it 'redirects to index page' do
        post :update, :id => @role, :role => {:role => 'foo', :onid => 'john'}
        expect(response).to redirect_to(:action => :index)
      end
      it 'refuses to update the operator' do
        post :update, :id => @me, :role => {:role => 'foo', :onid => 'fakeuser'}
        @me.reload
        expect(@me.role).to eq('admin')
      end
    end

    describe "POST 'destroy'" do
      before :each do
        @role = create(:role, :role => 'admin', :onid => 'foo')
        @me = Role.where(:onid => 'fakeuser').first
      end
      it 'deletes the role' do
        expect {
          post :destroy, :id => @role
        }.to change(Role, :count).by(-1)
      end
      it 'redirects to index page' do
        post :destroy, :id => @role
        expect(response).to redirect_to(:action => :index)
      end
      it 'refuses to delete the operator' do
        expect {
          post :destroy, :id => @me
        }.not_to change(Role, :count)
      end
    end
  end
end
