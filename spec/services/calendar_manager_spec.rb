describe CalendarManager do
  describe '.day' do
    context 'when no arguments are passed' do
      it "should be todays date" do
        expect(subject.day).to eq Time.current.midnight
      end
    end
    context "when a date is passed" do
      subject {CalendarManager.new(Date.new(2012,12,12))}
      it "should be that date" do
        expect(subject.day).to eq Time.zone.local(2012,12,12)
      end
    end
  end
end
