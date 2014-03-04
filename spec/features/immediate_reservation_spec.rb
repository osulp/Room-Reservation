require 'spec_helper'

describe "immediate reservation", :js => true do
  let(:user) {build(:user, :admin)}
  let(:room) {create(:room)}
  let(:room_2) {create(:room)}
  let(:reservation){}
  context "when logged in as an admin" do
    before(:each) do
      RubyCAS::Filter.fake(user.onid)
      create(:special_hour, open_time: "00:00:00", close_time: "00:00:00")
      room
      room_2
      reservation
      visit root_path
    end
    it "should have a button to view immediate reservations" do
      expect(page).to have_button "Immediate Reservation"
    end
    context "and the button is clicked" do
      before(:each) do
        expect(page).to have_button "Immediate Reservation"
        click_button "Immediate Reservation"
      end
      it "should show success bars for both" do
        within("#modal_skeleton") do
          expect(page).to have_selector(".bar-success", :count => 2)
        end
      end
      context "and one of the rooms has a reservation" do
        let(:reservation) {create(:reservation, :room => room, :start_time => Time.current.midnight, :end_time => Time.current.tomorrow.midnight)}
        it "should show success bars for only one" do
          within("#modal_skeleton") do
            expect(page).to have_selector(".bar-success", :count => 1)
          end
        end
        context "and you click the bar" do
          before(:each) do
            within("#modal_skeleton") do
              find(".bar-success").trigger("click")
            end
          end
          it "should show a reservation popup" do
            expect(page).to have_selector("#reservation-popup")
          end
        end
      end
    end
  end
end
