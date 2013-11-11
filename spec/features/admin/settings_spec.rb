require 'spec_helper'

describe 'settings administration' do
  context 'when logged in as an admin' do
    let(:user) {build(:user, :admin)}
    before(:each) do
      RubyCAS::Filter.fake(user.onid)
      visit admin_settings_path
      @setting = Setting.first
    end
    it "should show all available settings" do
      within(".admin-container") do
        expect(page).to have_content("Max Concurrent Reservations")
      end
    end
    context "when the setting is edited" do
      before(:each) do
        within("#edit_setting_#{@setting.id}") do
          fill_in("setting_value", :with => 1)
          click_button "Save"
        end
        expect(page).to have_content("Settings successfully saved")
      end
      it "should update the form" do
        within("#edit_setting_#{Setting.first.id}") do
          expect(find("#setting_value").value).to eq "1"
        end
      end
      it "should update the value in the database" do
        expect(Setting.first.value.to_i).to eq 1
      end
    end
  end
end
