require 'spec_helper'

describe "cleaning record administration" do
  context "as an admin" do
    let(:user) {build(:user, :admin)}
    let(:perform_setup) {nil}
    before(:each) do
      RubyCAS::Filter.fake(user.onid)
      perform_setup
      visit admin_cleaning_records_path
    end
    context "when there are cleaning records" do
      let(:cleaning_record) {create(:cleaning_record)}
      let(:perform_setup) do
        cleaning_record
      end
      it "should show it" do
        expect(page).to have_selector(".cleaning-record")
      end
      context "when it is attached to a room" do
        let(:room_1) {create(:room)}
        let(:room_2) {nil}
        let(:cleaning_record) {create(:cleaning_record, :rooms => [room_1])}
        context "and it is all rooms on a floor" do
          it "should say the floor name" do
            expect(page).to have_content("Floor 1")
          end
        end
        context "and there are other rooms on that floor" do
          let(:room_2) {create(:room, :floor => room_1.floor)}
          let(:perform_setup) do
            cleaning_record
            room_2
          end
          it "should say the room name" do
            expect(page).to have_content(room_1.name)
            expect(page).not_to have_content("Floor 1")
          end
        end
      end
      it "should be deletable" do
        expect(page).to have_selector(".cleaning-record")
        find("a[href='/admin/cleaning_records/#{cleaning_record.id}'][data-method='delete']").click
        expect(page).not_to have_selector(".cleaning-record")
        expect(page).to have_content("Cleaning record deleted")
        expect(CleaningRecord.all.size).to eq 0
      end
      it "should be able to be edited" do
        click_link "Edit"
        page.select "00", :from => "cleaning_record_start_time_4i"
        page.select "00", :from => "cleaning_record_start_time_5i"
        page.select "09", :from => "cleaning_record_end_time_4i"
        page.select "00", :from => "cleaning_record_end_time_5i"
        click_button "Save"
        expect(page).to have_content("Cleaning Record Updated")
        expect(CleaningRecord.last.start_time.utc.hour).to eq 0
        expect(CleaningRecord.last.end_time.utc.hour).to eq 9
      end
    end
    context "when the new record button is clicked" do
      let(:room) {create(:room)}
      before(:each) do
        room
        click_link "New Cleaning Record"
      end
      it "should show a form" do
        expect(page).to have_selector("form")
      end
      context "and the filter buttons are used", :js => true do
        context "and the all rooms button is clicked" do
          before(:each) do
            find("#all_rooms").click()
          end
          it "should check all the rooms" do
            expect(find("#cleaning_record_room_ids_#{room.id}")).to be_checked
          end
        end
        context "and the floor button is clicked" do
          before(:each) do
            find("#floor_1").click
          end
          it "should check all rooms on that floor" do
            expect(find("#cleaning_record_room_ids_#{room.id}")).to be_checked
          end
          it "should be unchecked when all rooms is clicked" do
            expect(find("#floor_1")).to be_checked
            find("#all_rooms").click()
            expect(find("#floor_1")).not_to be_checked
          end
          it "should be unchecked when a room is checked off" do
            expect(find("#floor_1")).to be_checked
            find("#cleaning_record_room_ids_#{room.id}").click
            expect(find("#floor_1")).not_to be_checked
          end
        end
      end
      context "when the form is filled out" do
        before(:each) do
          page.select "00", :from => "cleaning_record_start_time_4i"
          page.select "00", :from => "cleaning_record_start_time_5i"
          page.select "09", :from => "cleaning_record_end_time_4i"
          page.select "00", :from => "cleaning_record_end_time_5i"
          %w{Sun Mon Tues Wed Thur Fri Sat}.each do |day|
            page.check day
          end
          p
          page.check room.name
          click_button "Save"
          expect(page).to have_content "Succesfully Created Cleaning Record"
        end
        it "should create the record" do
          expect(CleaningRecord.all.size).to eq 1
          c = CleaningRecord.first
          expect(c.start_time.utc.hour).to eq 0
          expect(c.end_time.utc.hour).to eq 9
          expect(c.weekdays).to eq ["0","1","2","3","4","5","6"]
        end
        it "should show the record on the home page" do
          c = CleaningRecord.first
          create(:special_hour, open_time: "00:00:00", close_time: "00:00:00")
          visit root_path(:day => c.start_date)
          expect(page).to have_selector(".bar-danger", :count => 1)
        end
      end
    end
  end
end
