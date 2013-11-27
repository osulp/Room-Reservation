require 'spec_helper'

describe 'settings administration' do
  context 'when logged in as an admin' do
    let(:user) {build(:user, :admin)}
    before(:each) do
      RubyCAS::Filter.fake(user.onid)
      visit admin_settings_path
    end
    %w{max_concurrent_reservations announcement_header_message day_limit from_address from_name cancellation_email}.each do |setting|
      describe setting do
        it_behaves_like 'a setting', setting
      end
    end
    %w{max_concurrent_reservations day_limit}.each do |setting|
      describe setting do
        it_behaves_like 'only accepting numerical value', setting
      end
    end
    it "should organize miscellaneous settings first" do
      expect(all("th").first).to have_content("Miscellaneous Settings")
    end
    it "should persist the setting being changed" do
      expect(page).to have_content("Max Concurrent Reservations")
      s = Setting.where(:key => "announcement_header_message").first!
      within("#edit_setting_#{s.id}") do
        fill_in "setting_value_#{s.id}", :with => "Blabla"
        click_button "Save"
      end
      visit root_path
      expect(page).to have_content("Blabla")
      visit admin_settings_path
      within("#edit_setting_#{s.id}") do
        fill_in "setting_value_#{s.id}", :with => "Blabla2"
        click_button "Save"
      end
      visit root_path
      expect(page).to have_content("Blabla2")
    end
  end
end
