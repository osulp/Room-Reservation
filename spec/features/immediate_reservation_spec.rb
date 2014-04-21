require 'spec_helper'

describe "immediate reservation", :js => true do
  let(:user) {build(:user, :admin)}
  let(:room) {create(:room, :floor => 1)}
  let(:room_2) {create(:room, :floor => 1)}
  let(:room_3) {create(:room, :floor => 2)}
  let(:filter_1) do
    f = build(:filter)
    f.rooms << [room, room_3]
    f.save
    f
  end
  let(:reservation){}
  context "when logged in as an admin" do
    before(:each) do
      RubyCAS::Filter.fake(user.onid)
      create(:special_hour, open_time: "00:00:00", close_time: "00:00:00")
      room
      room_2
      room_3
      filter_1
      reservation
      visit root_path
    end
    it "should have a button to view immediate reservations" do
      expect(page).to have_button "Immediate Reservation"
    end
    context "and the rooms are filtered" do
      before(:each) do
        expect(page).to have_selector(".bar-success", :count => 2)
        find("#filter-#{filter_1.id}").click
        expect(page).to have_selector(".bar-success", :count => 1)
      end
      context "and immediate reservations is clicked" do
        before do
          expect(page).to have_button "Immediate Reservation"
          click_button "Immediate Reservation"
        end
        it "should show success bars for all the unfiltered rooms" do
          within("#modal_skeleton") do
            expect(page).to have_selector(".bar-success", :count => 2)
          end
        end
      end
    end
    context "and the button is clicked" do
      before(:each) do
        expect(page).to have_button "Immediate Reservation"
        click_button "Immediate Reservation"
      end
      it "should show success bars for both" do
        within("#modal_skeleton") do
          expect(page).to have_selector(".bar-success", :count => 3)
        end
      end
      it "should show what time they're available until" do
        time = 24.hours - Time.current.hour.hours - (((Time.current.min/10).ceil+1)*10).minutes
        new_time = Time.zone.at((Time.current.to_f/10.minutes).ceil*10.minutes)+time
        within("#modal_skeleton") do
          expect(page).to have_content(new_time.strftime("%H:%M"))
        end
      end
      context "and one of the rooms has a reservation" do
        let(:reservation) {create(:reservation, :room => room, :start_time => Time.current.midnight, :end_time => Time.current.tomorrow.midnight)}
        it "should show success bars for only one" do
          within("#modal_skeleton") do
            expect(page).to have_selector(".bar-success", :count => 2)
          end
        end
        context "and you click the bar" do
          before(:each) do
            within("#modal_skeleton") do
              expect(page).to have_selector(".bar-success")
              all(".bar-success").first.trigger("click")
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
