class Ability
  include CanCan::Ability

  def initialize(user)
    # Make administrators superheros. They can do whatever they want.
    if user.admin?
      can :manage, :all
    end
    # Staff permissions
    if user.staff?
      can [:assign_keycard, :ignore_restrictions], Reserver
      can [:view_past_dates], :calendar
      can [:manage], Reservation
    end
    # Reservation
    can :destroy, Reservation, :user_onid => user.onid
  end
end
