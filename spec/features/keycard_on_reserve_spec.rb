require 'spec_helper'
describe "Keycard Popup", :js => true do
  let(:user) {build(:user)}
  let(:keycard_enabled) {false}
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
    create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
    create(:room)
    APP_CONFIG["keycards"].stub(:[]).with("enabled").and_return(keycard_enabled)
    visit root_path
    find(".bar-success").click
    expect(page).to have_selector("#reservation-popup")
  end
  context "when keycards are disabled" do
    context "when the user is not an admin" do
      it "should not show the keycard field" do
        within("#reservation-popup") do
          expect(page).not_to have_field("Keycard")
        end
      end
    end
    context "when the user is an admin" do
      let(:user) {build(:user, :admin)}
      it "should not show the keycard field" do
        within("#reservation-popup") do
          expect(page).not_to have_field("Keycard")
        end
      end
    end
  end
  context "when keycards are enabled" do
    let(:keycard_enabled) {true}
    context "when the user is not an admin" do
      it "should not show the keycard field" do
        within("#reservation-popup") do
          expect(page).not_to have_field("Keycard")
        end
      end
    end
    %w{admin staff}.each do |type|
      context "when the user is a #{type}" do
        let(:user) {build(:user, type.to_sym)}
        it "should show the keycard field" do
          within("#reservation-popup") do
            expect(page).to have_field("Keycard")
          end
        end
      end
    end
  end
end
