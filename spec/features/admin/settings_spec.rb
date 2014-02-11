require 'spec_helper'

describe 'settings administration' do
  context 'when logged in as an admin' do
    let(:user) {build(:user, :admin)}
    before(:each) do
      RubyCAS::Filter.fake(user.onid)
      visit admin_settings_path
    end
    %w{max_concurrent_reservations announcement_header_message day_limit from_address from_name cancellation_email reservation_email update_email reservation_padding}.each do |setting|
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
    describe "reservation time settings", :js => true do
      before(:each) do
        expect(page).to have_content("User Reservation Limits")
        @setting = Setting.where(:key => "reservation_times").first!
      end
      context "when a new time is added" do
        before(:each) do
          fill_in "new-key", :with => "Test"
          click_button "Add Key"
        end
        it "should display" do
          expect(page).to have_selector("input[name='setting[value][Test]']")
        end
        context "and then saved" do
          before(:each) do
            expect(page).to have_selector("input[name='setting[value][Test]']")
            within("#edit_setting_#{@setting.id}") do
              fill_in "setting[value][Test]", :with => 30
              click_button "Save"
            end
            expect(page).to have_content "Settings successfully saved"
          end
          it "should persist" do
            expect(Setting.reservation_times["Test"]).to eq "30"
          end
          context "and then deleted" do
            before(:each) do
              all("a.close").last.click
              expect(page).not_to have_selector("input[name='setting[value][Test]']")
              within("#edit_setting_#{@setting.id}") do
                click_button "Save"
              end
              expect(page).to have_content "Settings successfully saved"
            end
            it "should delete it" do
              expect(Setting.reservation_times["Test"]).to be_nil
            end
          end
        end
      end
      %w{default admin}.each do |type|
        it "should not be able to delete the #{type} setting" do
          expect(page).to have_selector("input[name='setting[value][#{type}]']")
          page.execute_script("$('input[name=\\'setting[value][#{type}]\\']').remove()")
          expect(page).not_to have_selector("input[name='setting[value][#{type}]']")
          within("#edit_setting_#{@setting.id}") do
            click_button "Save"
          end
          expect(page).to have_content "Settings successfully saved"
          expect(page).to have_selector("input[name='setting[value][#{type}]']")
        end
      end
    end
  end
end
