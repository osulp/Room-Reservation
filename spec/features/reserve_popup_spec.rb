require 'spec_helper'

describe 'reserve popup' do
  include VisitWithAfterHook
  def set_reservation_time
    # Set start and end time to a valid time.
    start_time = (Time.current+1.hour).iso8601
    end_time = (Time.current+1.hour+10.minutes).iso8601
    page.execute_script("$('#reservation-popup').find('#reserver_start_time').val('#{start_time}');")
    page.execute_script("$('#reservation-popup').find('#reserver_end_time').val('#{end_time}');")
  end
  def after_visit(*args)
    disable_day_truncation
  end
  let(:user) {build(:user)}
  # TODO: Test this. Can't think of a good way to do it - The gateway filter would break things.
  context "when the user isn't logged in" do
    it "shouldn't show a popup on click"
  end
  let(:banner_record) {nil}
  context "when the user is logged in", :js => true do
    before(:all) do
      Timecop.return
    end
    let(:fake) {RubyCAS::Filter.fake(user.onid)}
    before(:each) do
      fake
      create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
      banner_record
      create(:room)
      visit root_path
    end
    it_should_behave_like "a popup", ".bar-success", "#reservation-popup"
    context "when a green bar is clicked" do
      before(:each) do
        find(".bar-success").trigger('click')
      end
      context "and they have no banner record" do
        it "should default to a 3 hour time range" do
          within("#reservation-popup") do
            expect(find(".start-time .picker").value).to eq("12:00 AM")
            expect(find(".end-time .picker").value).to eq("3:00 AM")
          end
        end
        describe "clicking yes" do
          context "when there is a swear word" do
            before(:each) do
              Reservation.destroy_all
              fill_in "reserver_description", :with => "Shit"
              set_reservation_time
              click_button "Reserve"
            end
            it "should show an error" do
              within("#reservation-popup") do
                expect(page).to have_content("innapropriate")
              end
            end
          end
          context "when everything is valid" do
            before(:each) do
              Reservation.destroy_all
              fill_in "reserver_description", :with => "Testing"
              set_reservation_time
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
              before(:each) do
                expect(page).to have_selector(".bar-info", :count => 1)
              end
              context "and the user has no banner record" do
                it "should not send an email" do
                  expect(ActionMailer::Base.deliveries).to be_empty
                end
                context "but they have an email from CAS" do
                  let(:fake) {RubyCAS::Filter.fake(user.onid, {:email => "bla@bla.org"})}
                  it "should send an email" do
                    expect(ActionMailer::Base.deliveries).not_to be_empty
                  end
                end
              end
              context "and the user has a banner record" do
                let(:banner_record) {create(:banner_record, :onid => user.onid, :status => "Undergraduate", :email => "bla@bla.org")}
                it "should send an email" do
                  expect(ActionMailer::Base.deliveries.length).to eq 1
                  email = ActionMailer::Base.deliveries.first
                  expect(email.subject).to eq Setting.email_reservation_subject
                  expect(email.body.to_s).to include user.onid
                  expect(email.body.to_s).to include user.banner_record.email
                  expect(email.body.to_s).to include Room.first.name
                end
              end
              it "should create a reservation" do
                expect(Reservation.all.length).to eq 1
              end
              it "should set the reservation's description" do
                expect(Reservation.first.description).to eq "Testing"
              end
              it "should update the view to display the new reservation" do
                expect(page).to have_selector(".bar-info", :count => 1)
              end
            end
          end
          context "when the user already has a reservation for that day" do
            before(:each) do
              create(:reservation, :user_onid => user.onid, :reserver_onid => user.onid)
            end
            context "when the application is configured to allow multiple reservations a day" do
              before(:each) do
                Setting.stub(:max_concurrent_reservations).and_return(0)
                # Need to wait for AJAX to finish changing the start/end time - there's likely a better way to do this.
                # TODO: Fix this.
                sleep(1)
                set_reservation_time
                click_button "Reserve"
              end
              it "should create a reservation" do
                expect(page).to have_content("Your reservation has been made!")
                expect(Reservation.all.length).to eq 2
              end
            end
            context "when the app is configured to allow 1 reservation a day" do
              before(:each) do
                Setting.stub(:max_concurrent_reservations).and_return(1)
                within("#reservation-popup") do
                  click_button "Reserve"
                end
              end
              it "should throw an error" do
                expect(page).to have_content("You can only make 1 reservation per day.")
              end
            end
            context "and the app is configured to allow 2 per day (and there are two)" do
              before(:each) do
                Setting.stub(:max_concurrent_reservations).and_return(2)
                create(:reservation, :user_onid => user.onid, :reserver_onid => user.onid, :start_time => Time.current.midnight+19.hours, :end_time => Time.current.midnight+20.hours)
                within("#reservation-popup") do
                  click_button "Reserve"
                end
              end
              it "should show a pluralized error" do
                expect(page).to have_content("You can only make 2 reservations per day.")
              end
            end
          end
          context "when the reservation is invalid" do
            before(:each) do
              # Reset reservation_user_onid to another user
              page.execute_script("$('#reserver_user_onid').val('other_user');")
              within("#reservation-popup") do
                fill_in "reserver_description", :with => "Testing"
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
              page.execute_script("$('#reserver_room_id').val('9');")
              within("#reservation-popup") do
                fill_in "reserver_description", :with => "Testing"
                click_button "Reserve"
              end
            end
            it "should display the error" do
              within("#reservation-popup") do
                expect(page).to have_content("The requested room does not exist")
              end
            end
            it "should not create a reservation" do
              expect(Reservation.all.length).to eq 0
            end
          end
        end
      end
      context "and they have a banner record" do
        context "and they are an undergraduate" do
          let(:banner_record) {create(:banner_record, :onid => user.onid, :status => "Undergraduate")}
          it "should default to a 3 hour time range" do
            within("#reservation-popup") do
              expect(find(".start-time .picker").value).to eq("12:00 AM")
              expect(find(".end-time .picker").value).to eq("3:00 AM")
            end
          end

          context "and they are staff" do
            let(:user) do
              User.any_instance.stub(:max_reservation_time).and_return(6.hours)
              build(:user, :staff)
            end
            it "should default to the configured time range" do
              within("#reservation-popup") do
                expect(find(".start-time .picker").value).to eq("12:00 AM")
                expect(find(".end-time .picker").value).to eq("6:00 AM")
              end
            end
          end
        end
        context "and their status is configured for 6 hours" do
          let(:banner_record) do
            Setting.stub(:reservation_times).and_return({"graduate" => "360"})
            create(:banner_record, :onid => user.onid, :status => "Graduate")
          end
          it "should set a 6 hour time range" do
            within("#reservation-popup") do
              expect(find(".start-time .picker").value).to eq("12:00 AM")
              expect(find(".end-time .picker").value).to eq("6:00 AM")
            end
          end
        end
      end
    end
  end
end
