require 'spec_helper'

describe "filters" do
  before(:each) do
    # Stub out being logged in
    RubyCAS::Filter.fake("person")
  end
  describe "filter views" do
    context "when there are filters" do
      before(:each) do
        @filter = create(:filter)
        visit root_path
      end
      it "should show the name" do
        expect(page).to have_content(@filter.name)
      end
      it "should have the 'all filters' box checked" do
        expect(find("#filter_all")).to be_checked
      end
      it "should not have that filter be checked by default" do
        expect(find("#filter-#{@filter.id}")).not_to be_checked
      end
    end
  end
  describe "clicking filters", :js => true do
    before(:each) do
      @filter = create(:filter)
      @filter_2 = create(:filter)
      @room = create(:room)
      @room.filters << @filter_2
      visit root_path
      page.should have_selector(".room-data", :count => 1)
    end
    describe "clicking a filter check box" do
      before(:each) do
        find("#filter-#{@filter.id}").click
      end
      it "should uncheck the all filter" do
        expect(find("#filter_all")).not_to be_checked
      end
      it "should hide all rooms that don't have that filter" do
        expect(page).not_to have_selector(".room-data")
      end
      describe "clicking the all filter box after that" do
        before(:each) do
          find("#filter_all").click
        end
        it "should uncheck the filter and check the all filter" do
          expect(find("#filter_all")).to be_checked
          expect(find("#filter-#{@filter.id}")).not_to be_checked
        end
        it "should show all rooms" do
          expect(page).to have_selector(".room-data", :count => 1)
        end
      end
    end
    describe "filter interaction" do
      before(:each) do
        @room_2 = create(:room, :floor => 1)
        @room_2.filters << @filter
        @room_3 = create(:room, :floor => 1)
        @room_3.filters << @filter
        @room_3.filters << @filter_2
        visit root_path
      end
      context "when multiple filters are selected" do
        before(:each) do
          find("#filter-#{@filter.id}").click
          find("#filter-#{@filter_2.id}").click
        end
        it "should check both boxes" do
          expect(find("#filter-#{@filter.id}")).to be_checked
          expect(find("#filter-#{@filter_2.id}")).to be_checked
        end
        it "should only display rooms where both filters apply" do
          expect(page).to have_selector(".room-data", :count => 1)
        end
      end
    end
    describe "clicking the all filters box" do
      context "when nothing else is checked" do
        before(:each) do
          find("#filter_all").click
        end
        it "should not work" do
          expect(find("#filter_all")).to be_checked
        end
      end
    end
  end
end