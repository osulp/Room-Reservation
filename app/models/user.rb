class User < OpenStruct
  def initialize(name, extra_params={})
    extra_params ||= {}
    extra_params[:onid] = name
    super(extra_params)
  end
end