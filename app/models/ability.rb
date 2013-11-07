class Ability
  include CanCan::Ability

  def initialize(user)
    # Make administrators superheros. They can do whatever they want.
    if user.admin?
      can :manage, :all
    end
    if user.staff?
      can [:assign_keycard, :ignore_restrictions], Reserver
    end
  end
end
