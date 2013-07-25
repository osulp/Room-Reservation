describe CalendarManager do
  describe '.day' do
    context 'when no arguments are passed' do
      it "should be todays date" do
        expect(subject.day).to eq Time.current.midnight
      end
    end
    context "when a day, month, and year are passed" do
      subject {CalendarManager.new({day: 12, month: 12, year: 2012})}
      it "should be that date" do
        expect(subject.day).to eq Time.zone.local(2012,12,12)
      end
    end
  end
end