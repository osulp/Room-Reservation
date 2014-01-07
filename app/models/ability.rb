class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.nil?
    # Make administrators superheros. They can do whatever they want.
    if user.admin?
      can :manage, :all
    end
    # Staff permissions
    if user.staff?
      can [:check_in, :check_out], KeyCard
      can [:assign_keycard, :ignore_restrictions], Reserver
      can [:ignore_restrictions], Canceller
      can [:view_past_dates], :calendar
      can [:manage], Reservation
      can [:read], BannerRecord
    end
    # Reservation
    can :destroy, Reservation, :user_onid => user.onid
  end
end
