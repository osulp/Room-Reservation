require 'spec_helper'

describe "staff shortcuts", :versioning => true do
  let(:user) {build(:user, :staff)}
  let(:keycard) {nil}
  let(:reservation) {nil}
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
    reservation
    keycard
    visit root_path
    expect(page).to have_content("Staff Shortcuts")
  end
  describe "keycard swipe", :js => true do
    before(:each) do
      fill_in "keycard_entry", :with => keycard.key
    end
    context "when an existing card is swiped" do
      context "which is checked out to a reservation" do
        let(:keycard) {create(:key_card_checked_out)}
        it "should show a success message" do
          within('#staff-shortcuts') do
            expect(page).to have_selector('.text-success')
            expect(page).to have_content("Key Card Checked In")
          end
        end
        it "should check the card in" do
          expect(page).to have_content('Key Card Checked In')
          expect(KeyCard.first.reservation).to eq nil
        end
      end
    end
  end
  describe "patron mode" do
    context "when the user is staff" do
      it "should not show" do
        expect(page).not_to have_selector("#patron_mode")
        expect(page).not_to have_content("Patron Mode")
      end
    end
    context "when the user is an admin" do
      let(:user) {build(:user, :admin)}
      it "should show" do
        expect(page).to have_selector("#patron_mode")
        expect(page).to have_content("Patron Mode")
      end
    end
  end
  describe "user search", :js => true do
    before(:each) do
      fill_in "user_lookup", :with => value
    end
    context "when a username is entered" do
      let(:value) {user.onid}
      context "when an ONID username is entered" do
        it "should bring up a modal window" do
          within("#modal_skeleton") do
            expect(page).to have_content("User Reservations (#{user.onid})")
          end
        end
      end
    end
    context "when an ID is entered" do
      let(:banner_record) do
        b = build(:banner_record, :onid => user.onid)
        b.osu_id = "931590800"
        b.save
        b
      end
      let(:value) do
        banner_record
        "931590800"
      end
      it "should bring up a modal window" do
        within("#modal_skeleton") do
          expect(page).to have_content("User Reservations (#{user.onid})")
        end
      end
      context "and it is a card swiped ID" do
        let(:value) do
          banner_record
          "11931590800"
        end
        it "should bring up a modal window" do
          within("#modal_skeleton") do
            expect(page).to have_content("User Reservations (#{user.onid})")
          end
        end
      end
      context "and the user has a reservation" do
        let(:reservation) do
          #create(:special_hour, open_time: "00:00:00", close_time: "00:00:00")
          create(:reservation, :user_onid => user.onid, :start_time => Time.current + 2.hours, :end_time => Time.current+4.hours)
        end
        it "should show it" do
          within("#modal_skeleton") do
            expect(page).to have_content("User Reservations")
            expect(page).to have_content(reservation.room.name)
            expect(page).not_to have_content("Empty")
          end
        end
        it "should have the time in 24h time" do
          within("#modal_skeleton") do
            expect(page).to have_content("User Reservations")
            expect(page).to have_content(reservation.start_time.strftime("%H:%M"))
            expect(page).to have_content(reservation.end_time.strftime("%H:%M"))
          end
        end
        it "should have a working cancel button" do
          sleep(1)
          click_link "Cancel"
          expect(page).to have_content("Cancel a reservation")
          click_link "Cancel It"
          expect(page).to have_content("cancelled")
          expect(Reservation.all.size).to eq 0
          within("#modal_skeleton") do
            expect(page).not_to have_link("Cancel")
          end
        end
        it "should have a working edit button" do
          sleep(1)
          within("#modal_skeleton") do
            click_link "Edit"
          end
          expect(page).to have_selector("#update-popup",:visible => true)
        end
        it "should maintain available times for the edit button" do
          sleep(1)
          within("#modal_skeleton") do
            click_link "Edit"
          end
          expect(page).to have_selector("#update-popup",:visible => true)
          page.execute_script("window.ReservationPopupManager.slider_element.slider('values', [0,1000]);")
          current_time = Time.zone.at((Time.current.to_f / 10.minutes).ceil * 10.minutes)
          expect(find(".start-time .picker").value).to eq(current_time.strftime("%l:%M %p").strip)
          expect(find(".end-time .picker").value).to eq("12:00 AM")
        end
        context "which has been truncated by the auto truncator" do
          let(:reservation) {create(:reservation, :user_onid => user.onid, :start_time => Time.current - 1.hours, :end_time => Time.current+1.hours)}
          let(:value) do
            banner_record
            OverdueTruncator.call
            expect(reservation.reload.truncated_at).not_to be_nil
            "931590800"
          end
          it "should say that it's been truncated" do
            expect(page).to have_content("Truncated")
          end
        end
        context "which already has a keycard attached" do
          let(:keycard) {create(:key_card, :room => reservation.room, :reservation => reservation)}
          it "should hide the keycard entry field" do
            within("#modal_skeleton") do
              expect(page).to have_content(reservation.room.name)
              expect(page).not_to have_selector(".keycard-checkout")
              expect(page).to have_content("Checked Out")
            end
          end
        end
        context "which still needs to be checked out" do
          it "should show the keycard entry field" do
            within("#modal_skeleton") do
              expect(page).to have_selector(".keycard-checkout")
            end
          end
          it "should focus on the keycard entry field" do
            within("#modal_skeleton") do
              expect(page).to have_selector(".keycard-checkout")
              sleep(1)
              expect(page.evaluate_script("document.activeElement.id")).to eq "keycard-checkout-#{reservation.id}"
            end
          end
          context "and a card is swiped" do
            let(:keycard) {create(:key_card, :room => reservation.room)}
            before(:each) do
              fill_in "keycard-checkout-#{reservation.id}", :with => keycard.key
            end
            it "should show a confirmation page" do
              expect(page).to have_content("Key Card Checked Out")
            end
            it "should reload the information" do
              expect(page).to have_content("Checked Out")
            end
          end
        end
        context "which is more than 12 hours in the future" do
          let(:reservation) {create(:reservation, :user_onid => user.onid, :start_time => Time.current + 13.hours, :end_time => Time.current+14.hours)}
          it "should hide the keycard entry field" do
            within("#modal_skeleton") do
              expect(page).to have_content(reservation.room.name)
              expect(page).not_to have_selector(".keycard-checkout")
            end
          end
        end
      end
    end
  end
end
