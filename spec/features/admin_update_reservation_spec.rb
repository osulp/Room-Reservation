require 'spec_helper'
describe "editing a reservation" do
  include VisitWithAfterHook
  def after_visit(*args)
    page.execute_script("window.CalendarManager.truncate_to_now = function(){}") if example.metadata[:js]
    page.execute_script("window.CalendarManager.go_to_today()") if example.metadata[:js]
    expect(page).to have_selector("#loading-spinner") if example.metadata[:js]
    expect(page).not_to have_selector("#loading-spinner") if example.metadata[:js]
  end
  let(:user) {build(:user)}
  let(:banner_record) {nil}
  before(:all) do
    Timecop.return
  end
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
    create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
    banner_record
    @room = create(:room)
    @start_time = Time.current.midnight+1.hours
    @end_time = Time.current.midnight+2.hours
  end
  context "when a regular user is logged in", :js => true do
    before(:each) do
      create(:reservation, start_time: @start_time+3.hours, end_time: @end_time+3.hours, user_onid: "otheruser", room: @room)
      create(:reservation, start_time: @start_time, end_time: @end_time, user_onid: user.onid, room: @room)
      visit root_path
      expect(page).to have_selector(".bar-info", :count => 1)
    end
    it "should not let them edit anything" do
      find(".bar-info").trigger(:mouseover)
      expect(page).not_to have_content("Click to Update")
    end
  end
  [true, false].each do |keycard_setting|
    context "when keycards are #{keycard_setting}", :versioning => true do
      before(:each) do
        APP_CONFIG[:keycards].stub(:[]).with(:enabled).and_return(keycard_setting)
      end
      context "when a staff member is logged in", :js => true do
        let(:user) {build(:user, :staff)}
        before(:each) do
          create(:reservation, start_time: @start_time, end_time: @end_time, user_onid: "otheruser", room: @room)
          visit root_path
          expect(page).to have_selector(".bar-info", :count => 1)
        end
        it "should have a tooltip for editing" do
          find(".bar-info").trigger(:mouseover)
          expect(page).to have_content("Click to Update")
        end
        context "when the bar is clicked" do
          before(:each) do
            find(".bar-info").trigger("click")
          end
          it "should display the start time" do
            within("#update-popup") do
              expect(page).to have_content(@start_time.strftime("%l:%M %p"))
            end
          end
          it "should display the end time" do
            within("#update-popup") do
              expect(page).to have_content(@end_time.strftime("%l:%M %p"))
            end
          end
          it "should let you change the time" do
            expect(page).to have_field("Username:", :with => "otheruser")
            end_time = (@end_time+20.minutes).iso8601.split("-")[0..-2].join("-")
            page.execute_script("$('#update-popup').find('#reserver_end_time').val('#{end_time}');")
            click_button "Reserve"
            expect(page).not_to have_field("Username:", :with => "otheruser")
            expect(page).to have_content("Until")
            expect(Reservation.last.end_time).to eq @end_time+20.minutes
          end
          context "when a reservation is edited" do
            before(:each) do
              expect(page).to have_field("Username:", :with => "otheruser")
              end_time = (@end_time+20.minutes).iso8601.split("-")[0..-2].join("-")
              page.execute_script("$('#update-popup').find('#reserver_end_time').val('#{end_time}');")
              click_button "Reserve"
              expect(page).not_to have_field("Username:", :with => "otheruser")
              expect(page).to have_content("Until")
            end
            context "and the user doesn't have a banner record" do
              it "should not send an email" do
                expect(ActionMailer::Base.deliveries).to be_empty
              end
            end
            context "and the user has a banner record" do
              let(:banner_record) {
                create(:banner_record, :onid => "otheruser", :email => "bla@bla.org")
              }
              it "should send an email" do
                expect(ActionMailer::Base.deliveries).not_to be_empty
                d = ActionMailer::Base.deliveries.first
                expect(d.body).to include("Your reservation has been edited")
              end
              it "should include the previous start time in the email" do
                d = ActionMailer::Base.deliveries.first
                expect(d.body).to include(@end_time.strftime("%B %-d, %Y %l:%M %p"))
              end
            end
          end
        end
      end
    end
  end
end
