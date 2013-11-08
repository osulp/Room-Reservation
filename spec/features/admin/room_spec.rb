require 'spec_helper'

describe "room administration" do
  let(:user) {build(:user, :admin)}
  let(:room) {create(:room)}
  let(:filter) {create(:filter)}
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
    room
    filter
    visit admin_rooms_path
  end
  context "when there are rooms defined" do
    it "should show them" do
      within(".admin-container") do
        expect(page).to have_content(room.name)
      end
    end
    it "should let you edit a room" do
      click_link "Edit"
      fill_in "room_name", :with => "Restroom"
      fill_in "room_floor", :with => "8"
      check filter.name
      click_button "Save"
      expect(page).to have_content("Room updated")
      expect(Room.last.name).to eq "Restroom"
      expect(Room.last.floor).to eq 8
      expect(Room.last.filters).to eq [filter]
    end
    it "should let you delete a room", :js => true do
      expect(page).to have_content(room.name)
      find("a[href='/admin/rooms/#{room.id}'][data-method='delete']").click
      expect(page).not_to have_content(room.name)
    end
  end
  it "should let you create a room" do
    click_link "New Room"
    fill_in "room_name", :with => "Restroom"
    fill_in "room_floor", :with => "8"
    check filter.name
    click_button "Create"
    expect(page).to have_content("Room added")
    expect(Room.last.name).to eq "Restroom"
    expect(Room.last.floor).to eq 8
    expect(Room.last.filters).to eq [filter]
  end
end
