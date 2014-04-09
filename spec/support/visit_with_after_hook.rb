module VisitWithAfterHook
  def visit(*args)
    super
    after_visit(*args)
  end

  def disable_day_truncation
    if example.metadata[:js]
      page.execute_script("window.CalendarManager.truncate_to_now = function(){}")
      page.evaluate_script("$(document).on('dayLoaded', function(){$('body').addClass('finished')});")
      page.execute_script("window.CalendarManager.go_to_today()")
      expect(page).to have_selector('body.finished')
    end
  end
end
