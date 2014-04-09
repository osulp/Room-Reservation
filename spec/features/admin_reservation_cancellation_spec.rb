require 'spec_helper'


describe 'cancelling a reservation' do
  include VisitWithAfterHook
  let(:banner_record) {nil}
  def after_visit(*args)
    disable_day_truncation
  end
  let(:user) {build(:user)}
  before(:all) do
    Timecop.return
  end
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
    create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
    banner_record
    @room = create(:room)
    @start_time = Time.current+1.hours
    @end_time = Time.current+2.hours
  end
  context "when a regular user is logged in", :js => true do
    before(:each) do
      create(:reservation, start_time: @start_time+3.hours, end_time: @end_time+3.hours, user_onid: "otheruser", room: @room)
      create(:reservation, start_time: @start_time, end_time: @end_time, user_onid: user.onid, room: @room)
      visit root_path
      expect(page).to have_selector(".bar-info", :count => 1)
    end
    it "should let them cancel their own reservation" do
      find(".bar-info").click
      click_link("Cancel")
      expect(page).to have_content("This reservation has been cancelled!")
      expect(Reservation.all.size).to eq 1
    end
  end
  context "when a staff member is logged in", :js => true do
    let(:user) {build(:user, :staff)}
    let(:perform_setup) {nil}
    before(:each) do
      create(:reservation, start_time: @start_time, end_time: @end_time, user_onid: "otheruser", room: @room)
      perform_setup
      visit root_path
      expect(page).to have_selector(".bar-info")
    end
    context "when the mouse is hovered over any user's reservation" do
      before(:each) do
        find(".bar-info").trigger(:mouseover)
      end
      it "should show the update tooltip" do
        expect(page).to have_content("Click to Update")
      end
      it "should show the owning user's name" do
        expect(page).to have_content("otheruser")
      end
    end
    context "and the reservation isn't clicked" do
      it "should not show the cancellation popup" do
        expect(page).to have_selector("#cancel-popup", :visible => false)
      end
    end
    it_should_behave_like "a popup", ".bar-info", "#update-popup"
    describe "clicking cancel" do
      before(:each) do
        find(".bar-info").click
        click_link("Cancel")
        click_link("Cancel It")
      end
      context "when the reservation has a keycard attached" do
        let(:perform_setup) do
          r = Reservation.first
          create(:key_card, :reservation => r, :room => r.room)
        end
        it "should check in the key card" do
          within("#cancel-popup") do
            expect(page).to have_content("This reservation has been cancelled!")
          end
          expect(KeyCard.last.reservation_id).to eq nil
          expect(Reservation.all.size).to eq 0
          expect(Reservation.with_deleted.last.key_card).to eq nil
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
      describe "then clicking to reserve again" do
        before(:each) do
          expect(page).to have_content("This reservation has been cancelled!")
          find(".bar-success").trigger('click')
        end
        it "should hide the cancel popup" do
          expect(page).not_to have_selector("#cancel-popup")
        end
      end
    end
    context "when the reservation is clicked" do
      before(:each) do
        find(".bar-info").click
        click_link "Cancel"
      end
      it "should display the owning user" do
        within("#cancel-popup") do
          expect(page).to have_content("otheruser")
        end
      end
      it "should ask if they want to cancel" do
        within("#cancel-popup") do
          expect(page).to have_content("Cancel It")
        end
      end
      it "should display the room name" do
        within("#cancel-popup") do
          expect(page).to have_content(@room.name)
        end
      end
      it "should display the start time" do
        within("#cancel-popup") do
          expect(page).to have_content(@start_time.strftime("%l:%M %p"))
        end
      end
      it "should display the end time" do
        within("#cancel-popup") do
          expect(page).to have_content(@end_time.strftime("%l:%M %p"))
        end
      end
    end
  end
end
