require 'spec_helper'

describe "key_card administration" do
  let(:user) {build(:user, :admin)}
  let(:room) {create(:room)}
  let(:key_card) {create(:key_card)}
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
    room
    key_card
    visit admin_key_cards_path
  end
  context "when there are keycards defined" do
    it "should show them" do
      within(".admin-container") do
        expect(page).to have_content(key_card.key)
      end
    end
    it "should let you edit a key card" do
      click_link "Edit"
      fill_in "key_card_key", :with => "87654321"
      choose room.name
      click_button "Save"
      expect(page).to have_content("Key Card updated")
      expect(KeyCard.last.key).to eq 87654321
      expect(KeyCard.last.room).to eq room
    end
    it "should let you delete a key card", :js => true do
      expect(page).to have_content(key_card.key)
      find("a[href='/admin/key_cards/#{key_card.id}'][data-method='delete']").click
      expect(page).not_to have_content(key_card.key)
      expect(page).to have_content("Key Card deleted")
    end
    it "should highlight a key when searching matches", :js => true do
      fill_in "keycard_filter", :with => key_card.key
      expect(page).to have_selector(".info")
    end
    it "should highlight nothing when searching does not match", :js => true do
      fill_in "keycard_filter", :with => 'bla' + key_card.key.to_s
      expect(page).not_to have_selector(".info")
    end
    context "when key card is checked out" do
      let(:key_card) {create(:key_card_checked_out)}
      it "should show the related reservation" do
        expect(page).to have_content(key_card.reservation.user_onid)
      end
    end
    context "when key card is returned" do
      it "should show available" do
        within(".admin-container") do
          expect(page).to have_content("Available")
        end
      end
    end
  end
  it "should let you create a key card" do
    click_link "New KeyCard"
    fill_in "key_card_key", :with => "87654321"
    choose room.name
    click_button "Save"
    expect(page).to have_content("Key Card added")
    expect(KeyCard.last.key).to eq 87654321
    expect(KeyCard.last.room).to eq room
  end
end
