class AdminResponder < ActionController::Responder
  def navigation_location(*args)
    [:admin, super].flatten
  end
end