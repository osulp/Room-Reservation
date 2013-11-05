shared_examples 'admin_panel' do
  let(:user) {nil}
  let(:banner_record) {nil}
  let(:build_role) {nil}
  before(:each) do
    RubyCAS::Filter.fake("fakeuser")
    RubyCAS::Filter.filter(self)
    build_role
    banner_record
  end
  context 'when user is not logged in' do
    it "should be unauthorized" do
      get :index
      expect(response.status).to eq 401 # Unauthorized
    end
  end

  context "when a user is logged in" do
    let(:banner_record) {create(:banner_record, :onid => "fakeuser", :osu_id => "931590000")}
    context "but not an admin" do
      let(:build_role) {create(:role, :role => :anythingelse, :onid  => "fakeuser")}
      it "should be unauthorized" do
        get :index
        expect(response.status).to eq 401 # Unauthorized
      end
    end

    context 'and is admin' do
      let(:build_role) {create(:role, :role => :admin, :onid  => "fakeuser")}
      it "returns http success" do
        get 'index'
        response.should be_success
      end
    end
  end
end