class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record=nil)
    @user   = user
    @record = record
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  def update?
    create?
  end

  def show?
    index?
  end

  def destroy?
    create?
  end
end
