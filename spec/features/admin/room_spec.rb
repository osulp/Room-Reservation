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
      fill_in "room_description", :with => "This is a restroom on 8th floor.\nEnjoy."
      check filter.name
      attach_file "room_image", 'spec/fixtures/sample.png'
      attach_file "room_floor_map", 'spec/fixtures/sample.png'
      click_button "Save"
      expect(page).to have_content("Room updated")
      room = Room.last
      expect(room.name).to eq "Restroom"
      expect(room.floor).to eq 8
      expect(room.description).to eq "This is a restroom on 8th floor.\nEnjoy."
      expect(room.filters).to eq [filter]
      expect(room.image).not_to be_blank
      expect(room.floor_map).not_to be_blank
      room.remove_image!
      room.remove_floor_map!
    end
    it "should let you delete the images" do
      click_link "Edit"
      attach_file "room_image", 'spec/fixtures/sample.png'
      attach_file "room_floor_map", 'spec/fixtures/sample.png'
      click_button "Save"
      room = Room.last
      expect(room.image).not_to be_blank
      expect(room.floor_map).not_to be_blank
      click_link "Edit"
      check "room_remove_image"
      check "room_remove_floor_map"
      click_button "Save"
      room = Room.last
      expect(room.image).to be_blank
      expect(room.floor_map).to be_blank
    end
    it "should let you delete a room", :js => true do
      expect(page).to have_content(room.name)
      find("a[href='/admin/rooms/#{room.id}'][data-method='delete']").click
      expect(page).not_to have_content(room.name)
      expect(page).to have_content("Room deleted")
    end
  end
  it "should let you create a room" do
    click_link "New Room"
    fill_in "room_name", :with => "Restroom"
    fill_in "room_floor", :with => "8"
    fill_in "room_description", :with => "This is a restroom on 8th floor.\nEnjoy."
    check filter.name
    attach_file "room_image", 'spec/fixtures/sample.png'
    attach_file "room_floor_map", 'spec/fixtures/sample.png'
    click_button "Save"
    expect(page).to have_content("Room added")
    room = Room.last
    expect(room.name).to eq "Restroom"
    expect(room.floor).to eq 8
    expect(room.description).to eq "This is a restroom on 8th floor.\nEnjoy."
    expect(room.filters).to eq [filter]
    expect(room.image).not_to be_blank
    expect(room.floor_map).not_to be_blank
    room.remove_image!
    room.remove_floor_map!
  end
end
