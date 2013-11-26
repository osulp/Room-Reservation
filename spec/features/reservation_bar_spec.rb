require 'spec_helper'

describe "GET / reservation bars" do
  include VisitWithAfterHook
  def after_visit(*args)
    expect(page).to have_content("Today") if example.metadata[:js]
    page.execute_script("window.CalendarManager.truncate_to_now = function(){}") if example.metadata[:js]
    page.execute_script("window.CalendarManager.go_to_today()") if example.metadata[:js]
  end

  let(:user) {"bla"}
  let(:login) {RubyCAS::Filter.fake(user) unless user.blank?}
  before(:each) do
    # Fake a login
    login
    # Start Time to be 1:00 AM January 1
    t = Time.local(2013, 1, 1, 1, 0, 0)
    Timecop.travel(t)
    # Make the hours "always open"
    create(:special_hour, open_time: "00:00:00", close_time: "00:00:00")
  end
  after(:each) do
    Timecop.return
  end
  describe "floor headers" do
    context "when there are no rooms" do
      before(:each) do
        visit root_path
      end
      it "should display no room headers" do
        expect(page).not_to have_selector('#tabs-floor .nav-tabs li')
      end
    end
    context "when there are rooms" do
      before(:each) do
        create(:room, :floor => 1)
        create(:room, :floor => 2)
        visit root_path
      end
      it "should display as many floor headers as there are rooms with those floors" do
        expect(page).to have_selector('#tabs-floor .nav-tabs li', :count => 2)
      end
    end
  end

  describe "room bars" do
    before(:each) do
      @room1 = create(:room, :floor => 1)
      @room2 = create(:room, :floor => 2)
      visit root_path
    end
    describe "viewing", :js => true do
      it "should show only the first floor's rooms" do
        expect(page).to have_selector('.room-data-bar', :count => 1)
      end
    end
    describe "clicking a room", :js => true do
      before(:each) do
        find("a[href='#floor-#{@room2.floor}']").click
      end
      it "should display the second room" do
        expect(page).not_to have_content(@room1.name)
        expect(page).to have_content(@room2.name)
      end
    end
    describe "reservation bars" do
      context "when there are no reservations" do
        it "should not show any red bars" do
          expect(page).not_to have_selector(".bar-danger")
          expect(page).to have_selector(".bar-success")
        end
      end
      context "when there are reservations" do
        before(:each) do
          Timecop.return
          create(:special_hour, open_time: "00:00:00", close_time: "00:00:00")
          r = create(:reservation, :start_time => Time.current.midnight, :end_time => Time.current.midnight+2.hours, :room => @room1)
          visit root_path
        end
        context "when user not logged in" do
          let(:user) {nil}
          let(:login) {RubyCAS::GatewayFilter.stub(:filter).and_return(true)}
          before(:each) do
            visit root_path
          end
          it "should show the red bar for the reservation", :js => true do
            sleep(1)
            expect(page).to have_selector(".bar-danger")
            expect(page).not_to have_selector(".bar-info")
            expect(page).to have_selector(".bar-success",:count => 2)
          end
        end
        context "and the reservation is for the user" do
          before(:each) do
            Reservation.destroy_all
            create(:reservation, :start_time => Time.current.midnight, :end_time => Time.current.midnight+2.hours, :room => @room1, :user_onid => "bla")
            visit root_path
          end
          it "should display the bar as a different color", :js => true do
            visit root_path

            expect(page).to have_selector(".bar-info")
          end
        end
        it "should show the red bar for the reservation" do
          expect(page).to have_selector(".bar-danger")
          expect(page).to have_selector(".bar-success",:count => 2)
        end

        describe "caching", :caching => true  do
          before(:each) do
            Rails.cache.clear
            visit root_path
            expect(page).to have_selector(".bar-danger", :count => 1)
          end
          context "when the page is visited again" do
            before(:each) do
              CalendarPresenter.should_receive(:new).exactly(1).times.and_call_original
              create(:reservation, :start_time => Time.current.midnight+5.hours, :end_time => Time.current.midnight+7.hours, :room => @room1)
              visit root_path
              expect(page).to have_selector(".bar-danger", :count => 2)
              visit root_path
            end
            it "should use a cache" do
              visit root_path
              expect(page).to have_selector(".bar-danger")
            end
          end
          context "when a new reservation is added" do
            it "should update the cache when a new reservation is added" do
              create(:reservation, :start_time => Time.current.midnight+5.hours, :end_time => Time.current.midnight+7.hours, :room => @room1)
              visit root_path
              expect(page).to have_selector(".bar-danger", :count => 2)
            end
          end
          context "when the reservation switches to be owned by them" do
            it "should update the cache", :js => true do
              r = create(:reservation, :start_time => Time.current.midnight+5.hours, :end_time => Time.current.midnight+7.hours, :room => @room1)
              visit root_path
              expect(page).not_to have_selector(".bar-info")
              r.user_onid = "bla"
              r.save
              visit root_path
              expect(page).to have_selector(".bar-info")
            end
          end
          context "when the time on the current reservation changes" do
            it "should update the cache", :js => true do
              visit root_path
              expect(page).to have_selector(".bar-danger")
              reservation = Reservation.first
              reservation.end_time = reservation.end_time + 2.hours
              reservation.save
              current_height = page.evaluate_script("$('.bar-danger').first().height()")
              visit root_path
              new_height = page.evaluate_script("$('.bar-danger').first().height()")
              expect(current_height).not_to eq new_height
            end
          end
          it "should update the cache when the time changes to a whole other day", :js => true do
            visit root_path
            reservation = Reservation.first
            reservation.start_time = reservation.start_time - 48.hours
            reservation.end_time = reservation.end_time - 48.hours
            reservation.save
            visit root_path
            expect(page).not_to have_selector(".bar-danger")
          end
          context "when a reservation is deleted" do
            it "should update the cache" do
              r = create(:reservation, :start_time => Time.current.midnight+5.hours, :end_time => Time.current.midnight+7.hours, :room => @room1)
              r2 = create(:reservation, :start_time => Time.current.midnight+8.hours, :end_time => Time.current.midnight+10.hours, :room => @room1)
              visit root_path
              expect(page).to have_selector(".bar-danger", :count => 3)
              Reservation.all[1].destroy
              visit root_path
              expect(page).to have_selector(".bar-danger", :count => 2)
            end
          end
        end
        context "when a bunch of dates are picked", :js => true do
          before(:each) do
            visit root_path
            # Disable the truncation for testing.
            page.execute_script("window.CalendarManager.truncate_to_now = function(){}")
            # Add counter for when $.get completes.
            page.execute_script("window.load_count = 0")
            page.execute_script("$.get_alt = $.get")
            page.execute_script("$.get = function(url, data, callback, type){var old_data = data; data = function(data_content){window.load_count++; $('body').addClass('count-'+window.load_count); old_data(data_content);}; $.get_alt(url, data, callback, type)}")
            # Artificially slow down loading the day
            page.execute_script("window.CalendarManager.day_changed_alt = window.CalendarManager.day_changed")
            page.execute_script("window.CalendarManager.day_changed = function(year, month, day){window.setTimeout(function(){window.CalendarManager.day_changed_alt(year,month,day)},100)}")
            all("#datepicker a")[2].click
            # Undo artificial slowdown
            page.execute_script("window.CalendarManager.day_changed = window.CalendarManager.day_changed_alt")
            find("button[data-handler=today]").click()
          end
          it "should load the last one" do
            # Expect 2 calls to load_day
            expect(page).to have_selector("body.count-2")
            expect(page).to have_selector(".bar-danger")
          end
        end
      end
    end
  end
end
