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
      it "should be able to be edited" do
        click_link "Edit"
        page.select "00", :from => "room_hour_start_time_4i"
        page.select "00", :from => "room_hour_start_time_5i"
        page.select "09", :from => "room_hour_end_time_4i"
        page.select "00", :from => "room_hour_end_time_5i"
        click_button "Save"
        expect(page).to have_content("Room Hour Updated")
        expect(RoomHour.last.start_time.utc.hour).to eq 0
        expect(RoomHour.last.end_time.utc.hour).to eq 9
      end
    end
    context "when the new button is clicked" do
      let(:room) {create(:room, :name => "BRoom")}
      let(:room_2) {create(:room, :name => "ARoom")}
      before(:each) do
        room
        room_2
        click_link "New Room Hour"
      end
      it "should show the header" do
        expect(page).to have_content("New Room Hour")
      end
      it "should show the form" do
        expect(page).to have_selector("form")
      end
      it "should sort rooms by name" do
        expect(page.body.index(room.name)).to be > page.body.index(room_2.name)
      end
      context "when there is an error in the form" do
        before(:each) do
          page.select "09", :from => "room_hour_start_time_4i"
          page.select "00", :from => "room_hour_start_time_5i"
          page.select "00", :from => "room_hour_end_time_4i"
          page.select "00", :from => "room_hour_end_time_5i"
          page.check room.name
          click_button "Save"
        end
        it "should show an error" do
          expect(page).to have_content("Start time must be before the end time.")
        end
      end
      context "when the form is filled out" do
        before(:each) do
          page.select "00", :from => "room_hour_start_time_4i"
          page.select "00", :from => "room_hour_start_time_5i"
          page.select "09", :from => "room_hour_end_time_4i"
          page.select "00", :from => "room_hour_end_time_5i"
          page.check room.name
          click_button "Save"
          expect(page).to have_content "Succesfully Created Room Hour"
        end
        it "should create the record" do
          r = RoomHour.first
          expect(r.start_time.hour).to eq 0
          expect(r.end_time.hour).to eq 9
          expect(r.rooms.first).to eq room
        end
      end
    end
  end
end
