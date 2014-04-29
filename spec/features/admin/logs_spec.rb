require 'spec_helper'
describe "Admin Logs" do
  let(:user) {build(:user, :admin)}
  let(:reservation) {create(:reservation, :user_onid => "joe")}
  let(:reservation_2) {create(:reservation, :start_time => reservation.start_time-1.minute)}
  let(:setup_methods) {nil}
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
    setup_methods
    visit admin_logs_path
  end
  context "when there are reservations" do
    let(:setup_methods) do
      reservation
      reservation_2
    end
    it "should show them" do
      expect(page).to have_content(reservation.user_onid)
    end
    context "and a username is searched" do
      before(:each) do
        fill_in 'ONID', :with => reservation.user_onid
        click_button 'Search'
      end
      it "should only show that reservation" do
        expect(page).to have_content(reservation.user_onid)
        expect(page).not_to have_content(reservation_2.user_onid)
      end
    end
    context "and an ID is swiped" do
      before(:each) do
        create(:banner_record, :onid => reservation.user_onid, :osu_id => "931590000")
        fill_in 'ONID', :with => "11931590000"
        click_button 'Search'
      end
      it "should only show that user's reservations" do
        expect(page).to have_content(reservation.user_onid)
        expect(page).not_to have_content(reservation_2.user_onid)
      end
    end
    context "and an ID is entered" do
      before(:each) do
        create(:banner_record, :onid => reservation.user_onid, :osu_id => "931590000")
        fill_in 'ONID', :with => "931590000"
        click_button 'Search'
      end
      it "should only show that user's reservations" do
        expect(page).to have_content(reservation.user_onid)
        expect(page).not_to have_content(reservation_2.user_onid)
      end
    end
    context "and they go to the next page" do
      let(:setup_methods) do
        reservation
        reservation_2
        LogsPresenter.any_instance.stub(:per_page).and_return(1)
      end
      it "should only show the the elements on the first page" do
        expect(page).not_to have_content(reservation_2.user_onid)
        expect(page).to have_selector("tr", :count => 1)
      end
      it "should view elements on the next page" do
        expect(page).to have_selector "li.next-page a[rel=next]"
        find("li.next-page a[rel=next]").click
        expect(page).to have_content(reservation_2.user_onid)
      end
    end
    context "and they click on a sortable column" do
      let(:setup_methods) do
        reservation
        reservation_2
      end
      before(:each) do
        expect(all("tr td").first).to have_content reservation.id
        find("a[data-sort=start_time]").click
      end
      it "should sort" do
        expect(all("tr td").first).to have_content reservation_2.id
      end
    end
    context "and they click a filterable column" do
      before(:each) do
        all("tr td a")[0].click # Click the first user.
      end
      it "should filter out all other columns" do
        expect(page).not_to have_content(reservation_2.user_onid)
      end
      it "should let them delete the filter" do
        expect(page).not_to have_content(reservation_2.user_onid)
        find(".close").click
        expect(page).to have_content(reservation_2.user_onid)
      end
      it "should not lose the filter when you sort" do
        find("a[data-sort=start_time]").click
        expect(page).not_to have_content(reservation_2.user_onid)
      end
      it "should not lose the filter when you search" do
        all("tr td a")[1].click # Click the first user.
        fill_in "ONID", :with => reservation_2.user_onid
        click_button "Search"
        expect(page).to have_selector(".close", :count => 2)
      end
    end
    context "and the reservation has a history", :versioning => true do
      before(:each) do
        reservation.start_time = reservation.start_time + 10.minutes
        reservation.save
        all("tr td a")[0].click # Click the first user.
        click_link "History"
      end
      it "should show the history" do
        expect(page).to have_selector("tr", :count => 4)
      end
    end
  end

  describe 'history', :versioning => true do
    let(:setup_methods) do
      reservation
    end
    context "when a reservation is cancelled" do
      before do
        reservation.destroy
        visit admin_logs_path
        click_link "History"
      end
      it "should show one history - an active record when it was created" do
        within("#history tbody") do
          expect(page).to have_selector("tr", :count => 1)
          expect(page).to have_content("Active")
        end
      end 
      it "should show its current state as cancelled" do
        within("#current_reservation") do
          expect(page).to have_content("Cancelled")
        end
      end
    end
  end
end
