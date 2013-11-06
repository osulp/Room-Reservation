require 'spec_helper'

describe "role administration" do
  context "as an admin" do
    let(:user) {build(:user, :admin)}
    let(:user_2) {build(:user, :staff)}
    before(:each) do
      RubyCAS::Filter.fake(user.onid)
      user_2
      visit admin_roles_path
    end
    context "when there are roles defined" do
      it "should show them" do
        within(".admin-container") do
          expect(page).to have_content(user.onid)
        end
      end
      it "should let you set another user's role" do
        within("#edit_role_#{user_2.roles.first.id}") do
          page.select('admin', :from => "role_role")
          click_button("Save")
        end
        expect(page).to have_content("Role updated")
        expect(user_2).to be_admin
      end
      it "should let you delete a role", :js => true do
        expect(page).to have_content(user_2.onid)
        find("a[href='/admin/roles/#{user_2.roles.first.id}'][data-method='delete']").click
        expect(page).not_to have_content(user_2.onid)
      end
    end
    it "should let you create a role" do
      click_link "New Role"
      fill_in "role_onid", :with => "Monkeys"
      click_button "Create"
      expect(page).to have_content("Role added")
      expect(Role.last.onid).to eq "Monkeys"
    end
  end
end
