module VisitWithAfterHook
  def visit(*args)
    super
    after_visit(*args)
  end
end