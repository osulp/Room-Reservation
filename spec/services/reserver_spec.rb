require 'spec_helper'

describe Reserver do
  before(:each) do
    Timecop.travel(Date.new(2013,8,29))
  end
  let(:user) {build(:user)}
  let(:reserver) {user}
  let(:room) {FactoryBot.create(:room)}
  let(:start_time) {Time.current.midnight+12.hours}
  let(:end_time) {Time.current.midnight+14.hours+10.minutes}
  subject {Reserver.new({:reserver_onid => reserver.onid, :user_onid => user.onid, :room_id => room.id, :start_time => start_time, :end_time => end_time})}
  describe "validations" do
    before(:each) do
      create(:special_hour, start_date: 60.days.ago, end_date: 60.days.from_now, open_time: '00:00:00', close_time: '00:00:00')
    end
    it {should validate_presence_of :start_time}
    it {should validate_presence_of :end_time}
    it {should validate_presence_of :room}
    it {should validate_presence_of :reserver_onid}
    it {should validate_presence_of :user_onid}
    it {should be_valid}
    context "when the key card key is given" do
      let(:user) {build(:user, :admin)}
      before(:each) do
        APP_CONFIG[:keycards].stub(:[]).with(:enabled).and_return(true)
      end
      context "and it exists" do
        let(:key_card) {create(:key_card)}
        subject {Reserver.new({:reserver_onid => reserver.onid, :user_onid => user.onid, :room_id => room.id, :start_time => start_time, :end_time => end_time, :key_card_key => key_card.key})}
        context "but it is for the wrong room" do
          it "should be invalid" do
            expect(subject).not_to be_valid
          end
        end
        context "and it is already checked out" do
          let(:key_card) {create(:key_card, :room => room, :reservation => create(:reservation, :room => room))}
          it "should be invalid" do
            expect(subject).not_to be_valid
          end
        end
        context "and it is not checked out" do
          let(:key_card) {create(:key_card, :room => room)}
          it "should be valid" do
            expect(subject).to be_valid
          end
        end
      end
    end
    context "when the duration is greater than what the user can have" do
      let(:end_time) {start_time + 4.hours}
      context "and the reserver is not an admin" do
        it "should be invalid" do
          expect(subject).not_to be_valid
        end
      end
      context "and the reserver is a staff member" do
        let(:reserver) {build(:user, :staff, :onid => user.onid)}
        it "should be valid" do
          expect(subject).to be_valid
        end
      end
    end
    context "when there is a reservation date limit" do
      let(:start_time) {Time.current.midnight+5.days+12.hours}
      let(:end_time) {Time.current.midnight+5.days+14.hours}
      let(:day_limit) {0}
      before(:each) do
        subject.stub(:day_limit).and_return(day_limit)
      end
      context "and it is 0" do
        it "should be valid" do
          expect(subject).to be_valid
        end
      end
      context "and it is less than the reservation request" do
        let(:day_limit) {2}
        context "and the reserver is staff" do
          let(:reserver) {build(:user, :staff)}
          it "should be valid" do
            expect(subject).to be_valid
          end
        end
        context "and the reserver is not staff" do
          it "should be invalid" do
            expect(subject).not_to be_valid
          end
        end
      end
    end
    context "when the reserver is not the same as the user" do
      let(:user) {build(:user)}
      let(:reserver) {build(:user)}
      context "and the reserver is staff" do
        let(:reserver) {build(:user, :staff)}
        it "should be valid" do
          expect(subject).to be_valid
        end
      end
      context "and the reserver is not an admin" do
        it "should be invalid" do
          expect(subject).not_to be_valid
        end
      end
    end
    context "when the reservation starts in the past" do
      let(:start_time){ Time.current.midnight-4.hours }
      let(:end_time){ Time.current.midnight-2.hours }
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
    context "when the given start time is greater than the end time" do
      let(:start_time) {end_time + 2.hours}
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
    context "when the start time is equal to the end time" do
      let(:start_time) {end_time}
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
    context "when the given timeframe is unavailable" do
      context "due to no hours" do
        before(:each) do
          Hours::SpecialHour.destroy_all
        end
        it "should be invalid" do
          expect(subject).not_to be_valid
        end
      end
      context "when another reservation exists already" do
        before(:each) do
          create(:reservation, start_time: Time.current.midnight+13.hours, end_time: Time.current.midnight+13.hours+10.minutes, room: room)
        end
        it "should be invalid" do
          expect(subject).not_to be_valid
        end
      end
    end
    context "when the max concurrency is set to 1" do
      before(:each) do
        Setting.stub(:max_concurrent_reservations).and_return(1)
      end
      context "and they have another reservation already" do
        before(:each) do
          @r1 = create(:reservation, :start_time => Time.current.midnight+1.hour, :end_time => Time.current.midnight+2.hours, :room => room, :user_onid => user.onid, :reserver_onid => other_user)
        end
        context "that was made by them" do
          let(:other_user) {user.onid}
          it "should be invalid" do
            expect(subject).not_to be_valid
          end
          context "and it's checked out" do
            before do
              APP_CONFIG[:keycards].stub(:[]).with(:enabled).and_return(true)
              @r1.key_card = create(:key_card, :room => @r1.room)
              @r1.save
            end
            context "and the reservation they're making is for the next day" do
              let(:start_time) {Time.current.tomorrow.midnight+1.hour}
              let(:end_time) {Time.current.tomorrow.midnight+2.hours}
              it "should be valid" do
                expect(subject).to be_valid
              end
            end
          end
        end
        context "that was made by an admin" do
          let(:other_user) {"bologna"}
          it "should be valid" do
            expect(subject).to be_valid
          end
          context "that has an attached keycard" do
            before(:each) do
              APP_CONFIG[:keycards].stub(:[]).with(:enabled).and_return(true)
              create(:key_card, :reservation => @r1, :room => room)
            end
            it "should be invalid" do
              expect(subject).not_to be_valid
            end
          end
        end
      end
      context "and they have a reservation that crosses midnight" do
        before(:each) do
          create(:reservation, start_time: Time.current.tomorrow.midnight-1.hour, end_time: Time.current.tomorrow.midnight+2.hours, room: room, user_onid: user.onid)
        end
        context "and the reservation is for the next day" do
          let(:start_time) {Time.current.tomorrow.midnight+13.hours}
          let(:end_time) {Time.current.tomorrow.midnight+15.hours}
          it "should be valid" do
            expect(subject).to be_valid
          end
        end
      end
      context "and they have a reservation for the next day" do
        before(:each) do
          create(:reservation, start_time: Time.current.tomorrow.midnight+13.hours, end_time: Time.current.tomorrow.midnight+15.hours, room: room, user_onid: user.onid)
        end
        context "and they make a reservation that crosses into that day" do
          let(:start_time) {Time.current.tomorrow.midnight-1.hour}
          let(:end_time) {Time.current.tomorrow.midnight+2.hours}
          it "should be valid" do
            expect(subject).to be_valid
          end
        end
      end
    end
    context "when there is another reservation for midnight the next day" do
      before(:each) do
        create(:reservation, start_time: Time.current.tomorrow.midnight, end_time: Time.current.tomorrow.midnight+2.hours, room: room, user_onid: user.onid)
      end
      context "and the reservation is for the current day" do
        let(:start_time) {Time.current.midnight+1.hours}
        let(:end_time) {Time.current.midnight+2.hours}
        context "and the max concurrency is set to 0" do
          before(:each) do
            Setting.stub(:max_concurrent_reservations).and_return(0)
          end
          it "should be valid" do
            expect(subject).to be_valid
          end
        end
        # This test ensures that midnight of the next day is considered as "the next day"
        context "and the max concurrency is set to 1" do
          before(:each) do
            Setting.stub(:max_concurrent_reservations).and_return(1)
          end
          it "should be valid" do
            expect(subject).to be_valid
          end
        end
      end
    end
  end
  describe ".save" do
    context "when the reserver is passed a reservation object" do
      before(:each) do
        create(:special_hour, start_date: 60.days.ago, end_date: 60.days.from_now, open_time: '00:00:00', close_time: '00:00:00')
        subject.save
        @reservation = Reservation.first
        @reservation.end_time = @reservation.end_time + 1.minute
        @new_reserver = Reserver.new(@reservation)
      end
      it "should be valid" do
        expect(@new_reserver).to be_valid
      end
      it "should persist changes on save" do
        expect(@new_reserver.save).to eq true
        expect(Reservation.first.end_time).to eq @reservation.end_time
      end
      context "which has a truncated_at set already" do
        before(:each) do
          @reservation = Reservation.first
          @reservation.truncated_at = Time.current
          @reservation.save
          @reservation.reload
          @reservation.end_time = @reservation.end_time + 1.minute
          @new_reserver = Reserver.new(@reservation)
        end
        it "should reset the truncated_at timestamp" do
          expect(@new_reserver.save).to eq true
          expect(Reservation.first.truncated_at).to be_nil
        end
      end
    end
    context "when the model is invalid" do
      before(:each) do
        subject.stub(:valid?).and_return(false)
      end
      it "should return false" do
        expect(subject.save).to eq false
      end
    end
    context "when it's valid" do
      before(:each) do
        create(:special_hour, start_date: 60.days.ago, end_date: 60.days.from_now, open_time: '00:00:00', close_time: '00:00:00')
        subject.save
      end
      it "should create a new reservation" do
        expect(Reservation.all.size).to eq 1
      end
      it "should be idempotent" do
        subject.save
        expect(Reservation.all.size).to eq 1
      end
      describe "reservation" do
        before(:each) do
          @reservation = Reservation.first
        end
        it "should have the given time frame" do
          expect(@reservation.start_time).to eq start_time
          expect(@reservation.end_time).to eq end_time
        end
        it "should set the reserver onid" do
          expect(@reservation.reserver_onid).to eq reserver.onid
        end
        it "should set the user onid" do
          expect(@reservation.user_onid).to eq user.onid
        end
      end
    end
  end
  describe ".to_json" do
    before(:each) do
      subject.save
    end
    it "should delegate to reservation" do
      expect(subject.to_json).to eq subject.reservation.to_json
    end
  end
end
