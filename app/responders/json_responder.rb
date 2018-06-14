class JsonResponder < ActionController::Responder

  def api_behavior
    raise MissingRenderer.new(format) unless has_renderer?

    if get?
      display resource
    elsif post?
      display resource, :status => :created, :location => api_location
    elsif patch? || put?
      display resource, :status => :ok
    else
      head :no_content
    end
  end

  def json_resource_errors
    {:errors => resource.errors.full_messages}
  end
end
