require 'spec_helper'

describe 'reserve popup' do
  include VisitWithAfterHook
  # TODO: Test this. Can't think of a good way to do it - The gateway filter would break things.
  context "when the user isn't logged in" do
    it "shouldn't show a popup on click"
  end
  let(:banner_record) {nil}
  context "when the user is logged in", :js => true do
    before(:all) do
      Timecop.return
    end
    before(:each) do
      RubyCAS::Filter.fake("fakeuser")
      create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
      banner_record
      create(:room)
      visit root_path
    end
    it "should hide the reservation popup" do
      expect(page).to have_selector("#reservation-popup", :visible => false)
    end
    context "when a green bar is clicked" do
      before(:each) do
        find(".bar-success").trigger('click')
      end
      it "should show the reservation popup" do
        expect(page).to have_selector("#reservation-popup", :visible => true)
      end
      describe "clicking outside the popup" do
        before(:each) do
          expect(page).to have_selector("#reservation-popup", :visible => true)
          find("body").trigger("click")
        end
        it "should hide the popup" do
          expect(page).not_to have_selector("#reservation-popup")
        end
      end
      context "and they have no banner record" do
        it "should default to a 3 hour time range" do
          within("#reservation-popup") do
            expect(find("#start-time")).to have_content("12:00 AM")
            expect(find("#end-time")).to have_content("3:00 AM")
          end
        end
        describe "clicking yes" do
          context "when everything is valid" do
            before(:each) do
              Reservation.destroy_all
              fill_in "reservation_description", :with => "Testing"
              click_button "Reserve"
            end
            it "should show a confirmation message" do
              within("#reservation-popup") do
                expect(page).to have_content("Your reservation has been made! Check your ONID email for details.")
              end
            end
            it "should show a loading message" do
              within("#reservation-popup") do
                expect(page).to have_content("Reserving...")
              end
            end
            context "when the reservation succeeds" do
              it "should create a reservation" do
                expect(page).to have_selector(".bar-info", :count => 1)
                expect(Reservation.scoped.length).to eq 1
              end
              it "should set the reservation's description" do
                expect(page).to have_selector(".bar-info", :count => 1)
                expect(Reservation.first.description).to eq "Testing"
              end
              it "should update the view to display the new reservation" do
                expect(page).to have_selector(".bar-info", :count => 1)
              end
            end
          end
          context "when the user already has a reservation for that day" do
            before(:each) do
              create(:reservation, :user_onid => "fakeuser")
            end
            context "when the application is configured to allow multiple reservations a day" do
              before(:each) do
                APP_CONFIG["reservations"].stub(:[]).with("max_concurrent_reservations").and_return(0)
                within("#reservation-popup") do
                  click_button "Reserve"
                end
              end
              it "should create a reservation" do
                expect(page).to have_content("Your reservation has been made!")
                expect(Reservation.scoped.length).to eq 2
              end
            end
            context "when the app is configured to allow 1 reservation a day" do
              before(:each) do
                APP_CONFIG["reservations"].stub(:[]).with("max_concurrent_reservations").and_return(1)
                within("#reservation-popup") do
                  click_button "Reserve"
                end
              end
              it "should throw an error" do
                expect(page).to have_content("You can only make 1 reservations per day.")
              end
            end
          end
          context "when the reservation is invalid" do
            before(:each) do
              # Reset reservation_user_onid to another user
              page.execute_script("$('#reservation_user_onid').val('other_user');")
              within("#reservation-popup") do
                fill_in "reservation_description", :with => "Testing"
                click_button "Reserve"
              end
            end
            it "should display the error" do
              within("#reservation-popup") do
                expect(page).to have_content("You are not authorized to reserve on behalf of")
              end
            end
            it "should not hide the popup form" do
              within("#reservation-popup") do
                expect(page).to have_selector(".popup-content")
              end
            end
          end
          context "when the room ID doesn't exist" do
            before(:each) do
              # Reset reservation_room_id to a non-existent
              page.execute_script("$('#reservation_room_id').val('9');")
              within("#reservation-popup") do
                fill_in "reservation_description", :with => "Testing"
                click_button "Reserve"
              end
            end
            it "should display the error" do
              within("#reservation-popup") do
                expect(page).to have_content("The requested room does not exist")
              end
            end
            it "should not create a reservation" do
              expect(Reservation.scoped.length).to eq 0
            end
          end
        end
      end
      context "and they have a banner record" do
        context "and they are an undergraduate" do
          let(:banner_record) {create(:banner_record, :onid => "fakeuser", :status => "Undergraduate")}
          it "should default to a 3 hour time range" do
            within("#reservation-popup") do
              expect(find("#start-time")).to have_content("12:00 AM")
              expect(find("#end-time")).to have_content("3:00 AM")
            end
          end
        end
        context "and their status is configured for 6 hours" do
          let(:banner_record) do
            APP_CONFIG["users"].stub(:[]).with("reservation_times").and_return({"graduate" => "360"})
            create(:banner_record, :onid => "fakeuser", :status => "Graduate")
          end
          it "should set a 6 hour time range" do
            within("#reservation-popup") do
              expect(find("#start-time")).to have_content("12:00 AM")
              expect(find("#end-time")).to have_content("6:00 AM")
            end
          end
        end
      end
    end
  end
end
def after_visit(*args)
  page.execute_script("window.CalendarManager.truncate_to_now = function(){}") if example.metadata[:js]
  page.execute_script("window.CalendarManager.go_to_today()") if example.metadata[:js]
  expect(page).to have_selector("#loading-spinner") if example.metadata[:js]
  expect(page).not_to have_selector("#loading-spinner") if example.metadata[:js]
end
