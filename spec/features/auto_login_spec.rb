require 'spec_helper'

describe "Automatic Login" do
  let(:ip_address) {nil}
  let(:auto_login) {nil}
  let(:user_ip) {"111.111.11.1"}
  let(:build_role) {nil}
  before(:each) do
    auto_login
    ip_address
    build_role
    ENV['RAILS_TEST_IP_ADDRESS'] = user_ip
    visit root_path
  end
  after(:each) do
    ENV['RAILS_TEST_IP_ADDRESS'] = nil
  end
  context "when an auto login record exists" do
    let(:auto_login) {
      a = create(:auto_login)
      create(:auto_login)
      a
    }
    context "and there is no IP associated" do
      it "should not automatically log in" do
        expect(page).not_to have_content(auto_login.username)
      end
    end
    context "and there is an IP associated" do
      let(:ip_address) {create(:ip_address, :ip_address => "222.222.22.2", :auto_login => auto_login)}
      context "and the user isn't from that IP" do
        it "should not automatically log in" do
          expect(page).not_to have_content(auto_login.username)
        end
      end
      context "and the user is from that IP" do
        let(:user_ip) {"222.222.22.2"}
        it "should automatically log in" do
          expect(page).to have_content(auto_login.username)
        end
        context "and the user is a staff member" do
          let(:build_role) {create(:role, :role => :staff, :onid => auto_login.username)}
          it "should login as an admin" do
            expect(page).to have_selector("#user-info[data-staff=true]")
          end
        end
        context "and the user is not an admin" do
          it "should not login as an admin" do
            expect(page).not_to have_selector("#user-info[data-staff=true]")
          end
        end
      end
    end
  end
end
