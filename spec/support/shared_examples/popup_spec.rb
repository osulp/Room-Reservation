shared_examples "a popup" do |initiator, selector|
  context "when the popup isn't clicked" do
    it "should not show the popup" do
      expect(page).to have_selector(selector, :visible => false)
    end
  end
  context "when the initiator is clicked" do
    before(:each) do
      find(initiator).click
    end
    it "should show the cancellation popup" do
      expect(page).to have_selector(selector, :visible => true)
    end
    describe "Closing" do
      describe "Clicking the X", :force => true do
        before(:each) do
          expect(page).to have_selector(selector, :visible => true)
          within(selector) do
            click_link("X")
          end
        end
        it "should hide the popup" do
          expect(page).not_to have_selector(selector)
        end
      end
      describe "clicking outside the popup" do
        before(:each) do
          expect(page).to have_selector(selector, :visible => true)
          find("body").trigger("click")
        end
        it "should hide the popup" do
          expect(page).not_to have_selector(selector)
        end
      end
    end
  end
end