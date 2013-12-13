require 'spec_helper'

describe "admin shortcuts" do
  let(:user) {build(:user, :staff)}
  let(:keycard) {nil}
  let(:reservation) {nil}
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
    reservation
    keycard
    visit root_path
    expect(page).to have_content("Admin Shortcuts")
  end
  describe "keycard swipe", :js => true do
    before(:each) do
      fill_in "keycard_entry", :with => keycard.key
    end
    context "when an existing card is swiped" do
      context "which is checked out to a reservation" do
        let(:keycard) {create(:key_card_checked_out)}
        it "should clear the keycard entry field" do
          expect(find_field("keycard_entry").value).to eq ""
        end
        it "should show a modal dialog" do
          expect(page).to have_content("Keycard Checkin")
        end
        it "should ask you to check the card in" do
          within("#modal_skeleton") do
            expect(page).to have_content("Would you like to check this card in?")
          end
        end
        it "should show you the reservation details" do
          within("#modal_skeleton") do
            expect(page).to have_content("Room")
            expect(page).to have_content(keycard.reservation.room.name)
          end
        end
      end
    end
  end
end
