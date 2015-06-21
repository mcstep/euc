module ApplicationHelper
  def sorted_regions
    User::REGIONS.sort_by{|x| x == current_user.home_region ? 0 : 1 }
  end

  def l(date)
    I18n.l date if date
  end
end
