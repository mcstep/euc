class StatPolicy < ApplicationPolicy
  def desktops?
    true
  end

  def sessions?
    true
  end

  def apps?
    true
  end
end