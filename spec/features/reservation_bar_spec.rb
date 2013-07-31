require 'spec_helper'

describe "GET / reservation bars" do
  describe "floor headers" do
    context "when there are no rooms" do
      before(:each) do
        visit root_path
      end
      it "should display no room headers" do
        expect(page).not_to have_selector('.nav-tabs li')
      end
    end
    context "when there are rooms" do
      before(:each) do
        2.times {create(:room)}
        visit root_path
      end
      it "should display as many floor headers as there are rooms with those floors" do
        expect(page).to have_selector('.nav-tabs li', :count => 2)
      end
    end
  end

  describe "room bars" do
    before(:each) do
      @room1 = create(:room, :floor => 1)
      @room2 = create(:room, :floor => 2)
      visit root_path
    end
    describe "viewing", :js => true do
      it "should show only the first floor's rooms" do
        expect(page).to have_selector('.room-data-bar', :count => 1)
      end
    end
    describe "clicking a room", :js => true do
      before(:each) do
        find("a[href='#floor-#{@room2.floor}']").click
      end
      it "should display the second room" do
        expect(page).not_to have_content(@room1.name)
        expect(page).to have_content(@room2.name)
      end
    end
    describe "reservation bars" do
      context "when there are no reservations" do
        it "should not show any red bars" do
          expect(page).not_to have_selector(".bar-danger")
        end
      end
      context "when there are reservations", :focus => true do
        before(:each) do
          r = create(:reservation, :start_time => Time.current.midnight, :end_time => Time.current.midnight+2.hours, :room => @room1)
          visit root_path
        end
        it "should show the red bar for the reservation" do
          expect(page).to have_selector(".bar-danger")
        end
      end
    end
  end
end