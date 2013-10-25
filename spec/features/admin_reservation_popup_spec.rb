require 'spec_helper'

describe "admin reservation popup", :js => true do
  include VisitWithAfterHook
  let(:build_role) {nil}
  let(:banner_record) {nil}
  before(:each) do
    RubyCAS::Filter.fake("fakeuser")
    build_role
    banner_record
    create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
    create(:room)
    visit root_path
    find('.bar-success').click
  end
  context "when the user is logged in" do
    context "and they are not an admin" do
      it "should not have an editable username" do
        expect(page).not_to have_selector("#reservation_user_onid[type='text']")
      end
    end
    context "and they are an admin" do
      let(:build_role) {create(:role, :role => :admin, :onid => "fakeuser")}
      it "should have an editable username" do
        expect(page).to have_selector("#reservation_user_onid[type='text']")
      end
      context "and they enter a banner ID" do
        let(:banner_record) {create(:banner_record, :onid => "fakeuser", :status => "Undergraduate", :osu_id => "921590000")}
        it "should fill in the username" do
          fill_in("reservation_user_onid", :with => "921590000")
          find("#reservation_user_onid").trigger("blur")
          expect(find("#reservation_user_onid").value).to eq "fakeuser"
        end
      end
    end
  end
end

def set_reservation_time
  # Set start and end time to a valid time.
  start_time = (Time.current+1.hour).iso8601.split("-")[0..-2].join("-")
  end_time = (Time.current+1.hour+10.minutes).iso8601.split("-")[0..-2].join("-")
  page.execute_script("$('#reservation_start_time').val('#{start_time}');")
  page.execute_script("$('#reservation_end_time').val('#{end_time}');")
end
def after_visit(*args)
  page.execute_script("window.CalendarManager.truncate_to_now = function(){}") if example.metadata[:js]
  page.execute_script("window.CalendarManager.go_to_today()") if example.metadata[:js]
  expect(page).to have_selector("#loading-spinner") if example.metadata[:js]
  expect(page).not_to have_selector("#loading-spinner") if example.metadata[:js]
end
