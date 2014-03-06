require 'spec_helper'

describe "GET /reservations", :versioning => true do
  let(:user) {"bla"}
  let(:login) {RubyCAS::Filter.fake(user) unless user.blank?}
  before(:each) do
    # Fake a login
    login
    # Make the hours "always open"
    create(:special_hour, open_time: "00:00:00", close_time: "00:00:00")
  end

  describe "reservation list" do
    before(:each) do
      @room1 = create(:room, :floor => 1)
      @room2 = create(:room, :floor => 2)
      visit my_reservations_path
    end
    context "when there are no reservations" do
      it "should not show any data" do
        expect(page).not_to have_selector(".reservation")
        expect(page).to have_content("Empty")
      end
    end
    context "when there are reservations" do
      before(:each) do
        Reservation.destroy_all
        r = create(:reservation, :start_time => Time.current.midnight, :end_time => Time.current.midnight+2.hours, :room => @room1, :user_onid => user)
      end
      context "and the reservation is in the future" do
        before(:each) do
          Timecop.travel(Time.current.midnight - 2.days)
          visit my_reservations_path
        end
        after(:each) do
          Timecop.return
        end
        it "should display as active" do
          expect(page).not_to have_content("Empty")
          expect(page).to have_selector(".reservation")
          expect(page).to have_content(@room1.name)
        end
        it "should display the time in 12h time" do
          r = Reservation.first
          expect(page).not_to have_content(r.start_time.strftime("%H:%M"))
          expect(page).not_to have_content(r.end_time.strftime("%H:%M"))
        end
        it "should not show an edit button" do
          expect(page).not_to have_content("Edit")
        end
        context "The cancel button", :js => true do
          it_should_behave_like "a popup", ".bar-info", "#cancel-popup"

          #TODO: Consider putting this block into shared examples
          describe "clicking cancel" do
            before(:each) do
              find(".bar-info").click
              within("#cancel-popup") do
                click_link("Cancel")
              end
            end
            it "should cancel the reservation" do
              expect(page).to have_content("Cancelled")
              expect(Reservation.all.size).to eq 0
            end
          end
        end
      end
      context "and the reservation is expired" do
        before(:each) do
          Timecop.travel(Time.current.midnight+1.day)
        end
        after(:each) do
          Timecop.return
        end
        context "and the reservation is checked out" do
          before(:each) do
            r = Reservation.last
            create(:key_card, :reservation => r, :room => r.room)
          end
          it "should show in the top as overdue" do
            visit my_reservations_path
            expect(page).not_to have_content("Empty")
            expect(page).to have_content "Key Card Overdue"
          end
        end
        it "should display as expired" do
          visit my_reservations_path
          expect(page).to have_content("Empty")
          expect(page).to have_selector(".reservation")
          expect(page).to have_content(@room1.name)
          expect(page).to have_content('Expired')
        end
      end
      context "and the reservation has been truncated" do
        before(:each) do
          r = Reservation.last
          r.start_time = Time.current-1.hour
          r.end_time = Time.current + 1.hour
          r.truncated_at = Time.current
          r.save
          visit my_reservations_path
        end
        it "should mark the reservation as not ongoing" do
          expect(page).to have_content("Empty")
        end
        it "should display the checkin time" do
          expect(page).to have_selector(".reservation")
          expect(page).to have_content(@room1.name)
          expect(page).to have_content('Checked In')
        end
      end
      context "and the reservation is cancelled" do
        it "should display as cancelled" do
          Reservation.last.destroy
          visit my_reservations_path
          expect(page).to have_content("Empty")
          expect(page).to have_selector(".reservation")
          expect(page).to have_content(@room1.name)
          expect(page).to have_content('Cancelled')
        end
      end

    end
  end
end
