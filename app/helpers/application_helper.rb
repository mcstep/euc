module ApplicationHelper
  def sorted_regions
    User::REGIONS.sort_by{|x| x == current_user.home_region ? 0 : 1 }
  end

  def l(date)
    I18n.l date if date
  end

  def permitted_attributes(record, *path)
    value = policy(record).permitted_attributes

    return value if path.empty?

    path.each do |chunk|
      value = value.find{|x| x.is_a?(Hash) && x[chunk]}.try(:[], chunk) || []
    end

    value
  end

  def writable?(record, *path)
    field = path.pop
    permitted_attributes(record, *path).include?(field)
  end

  def services
    %i(directory airwatch_instance google_apps_instance office365_instance horizon_instance)
  end

  def services_path
    service = services.find{|x| policy(x).index?}
    send :"#{service.to_s.pluralize}_path"
  end
end
