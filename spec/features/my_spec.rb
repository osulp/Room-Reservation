require 'spec_helper'

describe "GET /my" do
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
      visit my_path
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
          Timecop.travel(Time.current.midnight - 1.day)
          visit my_path
        end
        after(:each) do
          Timecop.return
        end
        it "should display as active" do
          expect(page).not_to have_content("Empty")
          expect(page).to have_selector(".reservation")
          expect(page).to have_content(@room1.name)
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
            it "should display a success message" do
              within("#cancel-popup") do
                expect(page).to have_content("This reservation has been cancelled!")
              end
            end
            it "should delete the reservation" do
              expect(page).to have_content("This reservation has been cancelled!")
              expect(Reservation.all.size).to eq 0
            end
          end
        end
      end
      context "and the reservation is expired" do
        it "should display as expired" do
          Timecop.travel(Time.current.midnight + 1.day)
          visit my_path
          expect(page).to have_content("Empty")
          expect(page).to have_selector(".reservation")
          expect(page).to have_content(@room1.name)
          expect(page).to have_content('Expired')
          Timecop.return
        end
      end
      context "and the reservation is cancelled" do
        it "should display as cancelled" do
          Reservation.last.destroy
          visit my_path
          expect(page).to have_content("Empty")
          expect(page).to have_selector(".reservation")
          expect(page).to have_content(@room1.name)
          expect(page).to have_content('Cancelled')
        end
      end

    end
  end
end
