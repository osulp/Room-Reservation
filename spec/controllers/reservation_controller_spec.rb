require 'spec_helper'

describe ReservationController do
  before(:each) do
    Timecop.travel(Date.new(2013,9,5))
  end
  describe "current_user_reservations" do
    context "when a user is not logged in" do
      before(:each) do
        get :current_user_reservations, :format => :json
      end
      it "should return a blank JSON array" do
        expect(JSON.parse(response.body)).to eq []
      end
    end
    context "when a user is logged in" do
      before(:each) do
        RubyCAS::Filter.fake("user")
        RubyCAS::Filter.filter(self)
      end
      context "when there are no reservations" do
        before(:each) do
          get :current_user_reservations, :format => :json
        end
        it "should return a blank JSON array" do
          expect(JSON.parse(response.body)).to eq []
        end
      end
      context "when another user has a reservation" do
        before(:each) do
          create(:reservation, start_time: Time.current+2.hours, end_time: Time.current+4.hours, user_onid: "dude")
          get :current_user_reservations, :format => :json
        end
        it "should return a blank JSON array" do
          expect(JSON.parse(response.body)).to eq []
        end
      end
      context "when the user has a reservation" do
        context "and the current day is requested" do
          context "and it's before the current day" do
            before(:each) do
              create(:reservation, start_time: Time.current.midnight-4.hours, end_time: Time.current.midnight-2.hours, user_onid: "user")
              get :current_user_reservations, :format => :json, :date => "2013-9-5"
            end
            it "should return a blank JSON array" do
              expect(JSON.parse(response.body)).to eq []
            end
          end
          context "and it's to come" do
            before(:each) do
              create(:reservation, start_time: Time.current+2.hours, end_time: Time.current+4.hours, user_onid: "user")
              get :current_user_reservations, :format => :json, :date => "2013-9-5"
            end
            it "should return a JSON array containing the reservation" do
              expect(JSON.parse(response.body).length).to eq 1
            end
          end
          context "and it's after the current day" do
            before(:each) do
              create(:reservation, start_time: Time.current.tomorrow.midnight+2.hours, end_time: Time.current.tomorrow.midnight+4.hours, user_onid: "user")
              get :current_user_reservations, :format => :json, :date => "2013-9-5"
            end
            it "should return a blank JSOn array" do
              expect(JSON.parse(response.body)).to eq []
            end
          end
        end
        context "and no day is given" do
          before(:each) do
            2.times {create(:reservation, start_time: Time.current.midnight-4.hours, end_time: Time.current.midnight-2.hours, user_onid: "user")}
            get :current_user_reservations, :format => :json
          end
          it "should return all reservations" do
            expect(JSON.parse(response.body).length).to eq 2
          end
        end
      end
    end
  end
end
