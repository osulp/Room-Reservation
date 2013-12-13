class KeyCardDecorator < Draper::Decorator
  delegate_all
  decorates_association :reservation

end
