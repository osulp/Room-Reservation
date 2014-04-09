require 'spec_helper'
describe "Keycard Popup", :js => true do
  include VisitWithAfterHook
  let(:user) {build(:user)}
  let(:keycard_enabled) {false}
  def set_reservation_time
    # Set start and end time to a valid time.
    start_time = (Time.current+1.hour).iso8601
    end_time = (Time.current+1.hour+10.minutes).iso8601
    page.execute_script("$('#reserver_start_time').val('#{start_time}');")
    page.execute_script("$('#reserver_end_time').val('#{end_time}');")
  end
  def after_visit(*args)
    disable_day_truncation
  end
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
    create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
    create(:room)
    APP_CONFIG[:keycards].stub(:[]).with(:enabled).and_return(keycard_enabled)
    visit root_path
    expect(page).to have_selector("button[data-handler='today']")
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
      it "should still be able to reserve normally" do
        set_reservation_time
        click_button "Reserve"
        within("#reservation-popup") do
          expect(page).to have_content("Your reservation has been made!")
        end
      end
    end
    context "when the user is an admin" do
      let(:user) {build(:user, :admin)}
      context "and they make a reservation" do
        before(:each) do
          set_reservation_time
        end
        context "without a key card" do
          before(:each) do
            fill_in "reserver_user_onid", :with => "bla"
            click_button "Reserve"
          end
          it "should work" do
            expect(page).to have_content("Until")
          end
        end
      end
    end
    context "when the user is staff" do
      let(:user) {build(:user, :staff)}
      context "and they make a reservation" do
        before(:each) do
          set_reservation_time
        end
        context "without a key card" do
          before(:each) do
            fill_in "reserver_user_onid", :with => "bla"
            click_button "Reserve"
          end
          it "should error" do
            within("#reservation-popup") do
              expect(page).to have_content("A key card must be swiped to make this reservation")
            end
          end
        end
        context "with a key card" do
          let(:keycard) {create(:key_card, :room => Room.first)}
          let(:key) {keycard.key}
          before(:each) do
            fill_in "reserver_user_onid", :with => "bla"
            fill_in "reserver_key_card_key", :with => key
            click_button "Reserve"
          end
          context "that does not exist" do
            let(:key) {"123123"}
            it "should error" do
              within("#reservation-popup") do
                expect(page).to have_content("Invalid keycard.")
              end
            end
          end
          context "that does exist" do
            it "should work" do
              within("#reservation-popup") do
                expect(page).to have_content("Until")
              end
              expect(Reservation.first.key_card).to eq keycard
            end
          end
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
