require 'spec_helper'

describe "auto login admin panel" do
  context "as an admin" do
    let(:user) {build(:user, :admin)}
    let(:perform_setup) {nil}
    before(:each) do
      RubyCAS::Filter.fake(user.onid)
      perform_setup
      visit admin_auto_logins_path
    end
    context "when there are auto logins" do
      let(:auto_login) {create(:auto_login, :username => "some_user")}
      let(:ip_address) {create(:ip_address, :auto_login => auto_login, :ip_address => "30.30.30.30")}
      let(:perform_setup) do
        auto_login
        ip_address
      end
      it "should show them" do
        expect(page).to have_content(auto_login.username)
      end
      it "should be deletable" do
        expect(page).to have_selector(".auto-login")
        find("a[href='/admin/auto_logins/#{auto_login.id}'][data-method='delete']").click
        expect(page).not_to have_selector(".auto-login")
        expect(page).to have_content("Auto Login deleted")
        expect(AutoLogin.all.size).to eq 0
      end
      it "should be editable", :js => true do
        click_link "Edit"
        expect(page).to have_selector("form")
        click_link "remove"
        click_link "Add IP Address"
        all("input[type=text]").last.set "128.128.128.128"
        click_button "Save"
        expect(page).to have_content("Auto Login Updated")
        p = AutoLogin.last
        expect(p.ip_addresses.size).to eq 1
        expect(p.ip_addresses.last.ip_address).to eq "128.128.128.128"
      end
    end
    context "when the new button is clicked" do
      before(:each) do
        click_link "New Auto Login"
      end
      it "should show the form" do
        expect(page).to have_selector("form")
      end
      context "and destroy IP address is clicked", :js => true do
        it "should hide an IP address field" do
          expect(page).to have_selector("#auto_login_ip_addresses_attributes_0_ip_address", :visible => true)
          click_link "remove"
          expect(page).not_to have_selector("#auto_login_ip_addresses_attributes_0_ip_address", :visible => true)
        end
      end
      context "and add ip address is clicked", :js => true do
        it "should add an IP address field" do
          expect(page).to have_selector("input[type=text]", :count => 2)
          click_link "Add IP Address"
          expect(page).to have_selector("input[type=text]", :count => 3)
        end
      end
      context "and it's submitted", :js => true do
        before(:each) do
          fill_in "Username", :with => "blabla"
          fill_in "Ip address", :with => "193.128.1.1"
          click_button "Save"
        end
        it "should save" do
          expect(page).to have_content("Successfully Created Auto Login")
          p = AutoLogin.first
          expect(p.ip_addresses.first.ip_address).to eq "193.128.1.1"
        end
      end
      context "and it's submitted with two ip_addresses", :js => true do
        before(:each) do
          fill_in "Username", :with => "blabla"
          fill_in "Ip address", :with => "193.128.1.1"
          click_link "Add IP Address"
          all("input[type=text]").last.set "128.128.128.128"
          click_button "Save"
        end
        it "should save multiple ip addresses" do
          expect(page).to have_content("Successfully Created Auto Login")
          p = AutoLogin.first
          expect(p.ip_addresses.size).to eq 2
        end
      end
    end
  end
end
