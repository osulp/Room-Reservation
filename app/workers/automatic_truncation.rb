class AutomaticTruncation
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(2) }

  def perform
    OverdueTruncator.call
  end
end