shared_examples "has clickable floor pickers" do
  let(:room_1) {create(:room, :floor => 1)}
  let(:room_2) {create(:room, :floor => 2)}
  before(:each) do
    room_1 && room_2
    visit current_path
  end
  it "should have a checkbox for both floors" do
    expect(page).to have_selector("#floor_1")
    expect(page).to have_selector("#floor_2")
  end
  it "should have a checkbox for all rooms" do
    expect(page).to have_selector("#all_rooms")
  end
  context "one floor's room is checked", :js => true do
    before(:each) do
      find("*[data-floor='1']").click
    end
    it "should check that floor" do
      expect(find("#floor_1")).to be_checked
    end
    it "should not check any other floors" do
      expect(find("#floor_2")).not_to be_checked
      expect(find("#all_rooms")).not_to be_checked
    end
  end
  context "and both floors are checked", :js => true do
    before(:each) do
      find("*[data-floor='1']").click
      find("*[data-floor='2']").click
    end
    it "should check both floors" do
      expect(find("#floor_1")).to be_checked
      expect(find("#floor_2")).to be_checked
    end
    it "should check the all rooms box" do
      expect(find("#all_rooms")).to be_checked
    end
  end
  context "and all rooms is checked", :js => true do
    before do
      find("#all_rooms").click
    end
    it "should check all the rooms" do
      expect(find("*[data-floor='1']")).to be_checked
      expect(find("*[data-floor='2']")).to be_checked
    end
    it "should check all the floor selectors" do
      expect(find("#floor_1")).to be_checked
      expect(find("#floor_2")).to be_checked
    end
    context "and then unchecked" do
      before do
        find("#all_rooms").click
      end
      it "should uncheck all the rooms" do
        expect(find("*[data-floor='1']")).not_to be_checked
        expect(find("*[data-floor='2']")).not_to be_checked
      end
      it "should uncheck all the floor selectors" do
        expect(find("#floor_1")).not_to be_checked
        expect(find("#floor_2")).not_to be_checked
      end
    end
  end
  context "and a floor button is checked", :js => true do
    before(:each) do
      find("#floor_1").click
    end
    it "should check all those floor's rooms" do
      expect(find("*[data-floor='1']")).to be_checked
    end
    it "should leave other floors alone" do
      expect(find("*[data-floor='2']")).not_to be_checked
    end
    context "and then another floor is checked" do
      before(:each) do
        find("#floor_2").click
      end
      it "should check all rooms" do
        expect(find("#all_rooms")).to be_checked
      end
      it "should check all the rooms in both floors" do
        expect(find("*[data-floor='1']")).to be_checked
        expect(find("*[data-floor='2']")).to be_checked
      end
      context "and then one floor is unchecked" do
        before do
          find("#floor_2").click
        end
        it "should only uncheck those floor's rooms" do
          expect(find("*[data-floor='1']")).to be_checked
          expect(find("*[data-floor='2']")).not_to be_checked
        end
        it "should uncheck all rooms" do
          expect(find("#all_rooms")).not_to be_checked
        end
      end
    end
    context "and then unchecked" do
      before do
        find("#floor_1").click
      end
      it "should uncheck all those floor's rooms" do
        expect(find("*[data-floor='1']")).not_to be_checked
      end
    end
  end
end
