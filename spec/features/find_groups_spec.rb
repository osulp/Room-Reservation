require 'spec_helper'

describe "finding groups", :js => true do
  before(:each) do
    # Stub out being logged in
    RubyCAS::Filter.fake("person")
    visit root_path
  end
  context "when the search groups button is clicked" do
    let(:reservation) {create(:reservation, :start_time => Time.current+1.hour, :end_time => Time.current+2.hours, :description => description)}
    let(:description) {""}
    let(:reservation_2) {create(:reservation, :start_time => Time.current+1.hour, :end_time => Time.current+2.hours, :description => description_2)}
    let(:description_2) {""}
    before(:each) do
      expect(page).to have_button("Today")
      reservation
      reservation_2
      find('#search-groups').trigger('click')
      expect(page).to have_content("Find Your Group")
    end
    context "and there are only reservations with no descriptions" do
      it "should not show them" do
        within("#modal_skeleton") do
          expect(page).not_to have_selector("td")
        end
      end
    end
    context "and there are reservations with descriptions" do
      let(:description) {"BBB"}
      let(:description_2) {"AAA"}
      it "should show them" do
        within("#modal_skeleton") do
          expect(page).to have_selector("tr", :count => 3)
          expect(page).to have_content('BBB')
        end
      end
      # TODO: Fix list.js or whatever is causing PhantomJS to throw a javascript error here.
      context "and you click to sort" do
        before(:each) do
          expect(page).to have_content("Description")
          all("#modal_skeleton th").first.click
          sleep(1)
        end
        xit "should sort" do
          expect(all("#modal_skeleton tbody td").first).to have_content("AAA")
        end
      end
      context "and you search" do
        before(:each) do
          fill_in "Search Groups", :with => "A"
        end
        xit "should search" do
          expect(page).to have_selector("#modal_skeleton tbody tr", :count => 1)
        end
      end
    end
  end
end
