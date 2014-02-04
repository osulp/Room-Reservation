require 'spec_helper'
describe "Admin Logs" do
  let(:user) {build(:user, :admin)}
  let(:reservation) {create(:reservation)}
  let(:setup_methods) {nil}
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
    setup_methods
    visit admin_logs_path
  end
  context "when there is a reservation" do
    let(:setup_methods) {reservation}
    it "should show it" do
      expect(page).to have_content(reservation.user_onid)
    end
  end
end