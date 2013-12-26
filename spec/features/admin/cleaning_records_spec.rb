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
