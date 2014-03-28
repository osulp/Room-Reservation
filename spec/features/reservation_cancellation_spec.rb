require 'spec_helper'

describe 'cancelling a reservation' do
  include VisitWithAfterHook
  def after_visit(*args)
    page.execute_script("window.CalendarManager.truncate_to_now = function(){}") if example.metadata[:js]
    page.execute_script("window.CalendarManager.go_to_today()") if example.metadata[:js]
    expect(page).to have_selector("#loading-spinner") if example.metadata[:js]
    expect(page).not_to have_selector("#loading-spinner") if example.metadata[:js]
  end
  before(:all) do
    Timecop.return
  end
  before(:each) do
    fake
    create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
    banner_record
    @room = create(:room)
    @start_time = Time.current+1.hours
    @end_time = Time.current+2.hours
    reservation
    visit root_path
  end
  let(:reservation) {create(:reservation, start_time: @start_time, end_time: @end_time, user_onid: "fakeuser", room: @room)}
  let(:banner_record) {nil}

  context "when the user is not logged in", :js => true do
    let(:fake) {RubyCAS::Filter.stub(:redirect_to_cas_for_authentication).and_return(true)}
    it "should show red only" do
      expect(page).to have_selector(".bar-danger", :count => 1)
    end
    it "should not show a cancel popup when clicked" do
      find(".bar-danger").click
      expect(page).not_to have_selector("#cancel-popup", :visible => true)
    end
  end

  context "when the user is logged in", :js => true do
    let(:fake) {RubyCAS::Filter.fake("fakeuser")}
    context "when you are the owner of the reservation" do
      before(:each) do
        expect(page).to have_selector(".bar-info")
      end
      context "when the mouse is hovered over the user's reservation" do
        before(:each) do
          find(".bar-info").trigger(:mouseover)
        end
        it "should show the cancellation tooltip" do
          expect(page).to have_content("Click to Cancel")
        end
      end
      context "and the reservation isn't clicked" do
        it "should not show the cancellation popup" do
          expect(page).to have_selector("#cancel-popup", :visible => false)
        end
      end
      it_should_behave_like "a popup", ".bar-info", "#cancel-popup"

      describe "clicking cancel" do
        before(:each) do
          find(".bar-info").click
          click_link("Cancel")
        end
        it "should display a success message" do
          within("#cancel-popup") do
            expect(page).to have_content("This reservation has been cancelled!")
          end
        end
        it "should delete the reservation" do
          expect(page).to have_content("This reservation has been cancelled!")
          expect(Reservation.all.size).to eq 0
        end
        context "when the user doesn't have a banner record" do
          it "should not send an email" do
            expect(page).to have_content("This reservation has been cancelled!")
            expect(ActionMailer::Base.deliveries.length).to eq 0
          end
          context "but they have an email from CAS" do
            let(:fake) {RubyCAS::Filter.fake("fakeuser", :email => "bla@bla.org")}
            it "should send an email" do
              expect(page).to have_content("This reservation has been cancelled!")
              expect(ActionMailer::Base.deliveries).not_to be_empty
            end
          end
        end
        context "when the user has a banner record" do
          let(:banner_record) {create(:banner_record, :onid => "fakeuser", :status => "Undergraduate", :email => "bla@bla.org")}
          it "should send an email" do
            expect(page).to have_content("This reservation has been cancelled!")
            expect(ActionMailer::Base.deliveries.length).to eq 1
            email = ActionMailer::Base.deliveries.first
            body = email.body.to_s
            expect(body).to include Room.first.name
            expect(body).to include "has been cancelled."
            expect(email.subject).to eq Setting.email_cancellation_subject
          end
        end
        describe "then clicking to reserve again" do
          before(:each) do
            expect(page).to have_content("This reservation has been cancelled!")
            find(".bar-success").trigger('click')
          end
          it "should hide the cancel popup" do
            expect(page).not_to have_selector("#cancel-popup")
          end
        end
      end
      context "when the reservation is clicked" do
        before(:each) do
          find(".bar-info").click
        end
        it "should ask if they want to cancel" do
          within("#cancel-popup") do
            expect(page).to have_content("Cancel")
          end
        end
        it "should display the room name" do
          within("#cancel-popup") do
            expect(page).to have_content(@room.name)
          end
        end
        it "should display the start time" do
          within("#cancel-popup") do
            expect(page).to have_content(@start_time.strftime("%l:%M %p"))
          end
        end
        it "should display the end time" do
          within("#cancel-popup") do
            expect(page).to have_content(@end_time.strftime("%l:%M %p"))
          end
        end
      end
    end
    context "when you are not the owner of the reservation" do
      let(:reservation) {create(:reservation, start_time: @start_time, end_time: @end_time, user_onid: "otheruser", room: @room)}
      describe "clicking cancel" do
        before(:each) do
          expect(page).to have_selector(".bar-danger", :count => 1)
          find(".bar-danger").click
        end
        it "should not show a cancel popup" do
          expect(page).not_to have_selector("#cancel-popup", :visible => true)
        end
      end
    end
  end
end
