require 'spec_helper'

describe "admin reservation popup", :js => true do
  include VisitWithAfterHook
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

  let(:user) {build(:user)}
  let(:banner_record) {nil}
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
    banner_record
    create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
    create(:room)
    visit root_path
    find('.bar-success').trigger("click")
  end
  context "when the user is logged in" do
    context "and they are not an admin" do
      it "should not have an editable username" do
        expect(page).not_to have_selector("#reservation_user_onid[type='text']")
      end
    end
    context "and they are an admin" do
      let(:user) {build(:user, :admin)}
      it "should have an editable username" do
        expect(page).to have_selector("#reservation_user_onid[type='text']")
      end
      context "and they enter a banner ID" do
        let(:banner_record) {create(:banner_record, :onid => "fakeuser", :status => "Undergraduate", :osu_id => "921590000")}
        it "should fill in the username when an ID is entered" do
          fill_in("reservation_user_onid", :with => "921590000")
          expect(page).to have_field("reservation_user_onid", :with => "fakeuser")
        end
        it "should fill in the username when a card is swiped" do
          fill_in("reservation_user_onid", :with => "11921590000")
          expect(page).to have_field("reservation_user_onid", :with => "fakeuser")
        end
        it "should work fine when a name is entered" do
          fill_in("reservation_user_onid", :with => "terrellt")
          find("#reservation_user_onid").trigger("blur")
          expect(page).to have_field("reservation_user_onid", :with => "terrellt")
        end
      end
      context "and they make a reservation for another user" do
        context "and the onid field isn't filled in" do
          before(:each) do
            set_reservation_time
            click_button "Reserve"
          end
          it "should error" do
            expect(page).to have_content("A username must be chosen to reserve for.")
          end
        end
        context "and the onid field is filled in" do
          let(:banner_record) {create(:banner_record, :onid => "fakeuser", :status => "Undergraduate", :osu_id => "921590000")}
          before(:each) do
            fill_in("reservation_user_onid", :with => "921590000")
            find("#reservation_user_onid").trigger("blur")
            set_reservation_time
            click_button "Reserve"
          end
          it "should show a confirmation message" do
            expect(page).to have_content("Room Reserved")
          end
          it "should show the room info" do
            within("#reservation-popup") do
              expect(page).to have_content(Room.first.name)
            end
          end
        end
      end
    end
  end
end