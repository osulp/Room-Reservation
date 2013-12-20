require 'spec_helper'

describe "staff shortcuts" do
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
    end
  end
end
