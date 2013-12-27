require 'spec_helper'

describe "Room Hours Administration" do
  context "as an admin" do
    let(:user) {build(:user, :admin)}
    let(:perform_setup) {nil}
    before(:each) do
      RubyCAS::Filter.fake(user.onid)
      perform_setup
      visit admin_room_hours_path
    end
    context "when there are room hours" do
      let(:room_hour) {create(:room_hour)}
      let(:perform_setup) {room_hour}
      it "should show them" do
        expect(page).to have_selector('.room-hour')
      end
      it "should be deletable" do
        expect(page).to have_selector(".room-hour")
        find("a[href='/admin/room_hours/#{room_hour.id}'][data-method='delete']").click
        expect(page).not_to have_selector(".room-hour")
        expect(page).to have_content("Room hour deleted")
        expect(RoomHour.all.size).to eq 0
      end
    end
  end
end
