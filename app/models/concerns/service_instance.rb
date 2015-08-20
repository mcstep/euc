module ServiceInstance
  def title
    display_name.blank? ? super : display_name
  end
end