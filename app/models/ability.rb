class Ability
  include CanCan::Ability

  def initialize(user)
    logger.debug("User:#{user}, Name:#{user.inspect},")
    user_groups = RoleMapper.roles(user.to_s)
    if user_groups.include? "admin"
      can :manage, :all
    else
      can :read, :all
    end
  end

end
