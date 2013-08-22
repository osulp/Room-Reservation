require 'spec_helper'

describe Room do
  subject { Room.create! :name => 'TestRoom', :floor => 4 }

  describe "validations" do
    it {should validate_presence_of(:name)}
    it {should validate_presence_of(:floor)}
    it {should validate_numericality_of(:floor).only_integer}
    it {should have_many :room_filters}
    it {should have_many(:filters).through(:room_filters)}
    it {should have_many :cleaning_record_rooms}
    it {should have_many(:cleaning_records).through(:cleaning_record_rooms)}
  end

  describe 'load_reservations_today' do
    it 'should only load reservations on the day' do
      now = Time.now
      subject.reservations.create! :user_onid => 'test-out', :reserver_onid => 'tester', :start_time => 1.days.from_now, :end_time => 2.days.from_now, :description => 'This is only a test record'
      subject.reservations.create! :user_onid => 'test-out', :reserver_onid => 'tester', :start_time => 1.days.ago, :end_time => now.midnight, :description => 'This is only a test record'
      subject.reservations.create! :user_onid => 'test-in', :reserver_onid => 'tester', :start_time => now.midnight - 1.hours, :end_time => now.midnight + 1.hours, :description => 'This is only a test record'
      subject.reservations.create! :user_onid => 'test-in', :reserver_onid => 'tester', :start_time => now.midnight + 7.hours, :end_time => now.midnight + 9.hours, :description => 'This is only a test record'
      subject.reservations.create! :user_onid => 'test-in', :reserver_onid => 'tester', :start_time => now.midnight + 23.hours, :end_time => now.midnight + 24.hours, :description => 'This is only a test record'
      subject.reservations.create! :user_onid => 'test-out', :reserver_onid => 'tester', :start_time => now.midnight + 24.hours, :end_time => now.midnight + 25.hours, :description => 'This is only a test record'
      reservations = subject.load_reservations_today now
      reservations.should have(3).items
      reservations.each do |r|
        r.user_onid.should eq('test-in')
      end
    end
  end

  describe 'load_special_hours_today' do
    it 'should only load special hours on the day' do
      now = Time.now
      special_hours = subject.load_special_hours_today now
      special_hours.each do |s|
        s.start_time.should < now.midnight + 1.day
        s.end_time.should > now.midnight
      end
    end
  end

  describe 'load_hours_today' do
    it 'should collect hours from different source' do
      now = Time.now
      subject.should_receive(:load_reservations_today).with(now).once
      subject.should_receive(:load_special_hours_today).with(now).once
      subject.load_hours_today now
    end
  end

end
