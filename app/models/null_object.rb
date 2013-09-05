class NullObject

  def nil?
    return true
  end

  def method_missing(method, *args, &block)
    return self
  end
end