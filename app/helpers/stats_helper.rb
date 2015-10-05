module StatsHelper
  def horizon_desktops_stats(user=current_user)
    return @horizon_desktop_stats if @horizon_desktop_stats

    kinds = {}
    stats = user.horizon_stats.group_by{|x| Date.parse(x['begin']).to_date}.map do |day, entities|
      result = { 'day' => day.to_s }
      entities.group_by{|x| x['title']}.each do |t,xs|
        key = t.gsub(/[-\.\s]+/,'').downcase

        result[key] = xs.length
        kinds[key]  = t
      end
      result
    end

    return @horizon_desktop_stats = {data: stats, kinds: kinds}
  end

  def horizon_sessions_stats(user=current_user)
    return @horizon_sessions_stats if @horizon_sessions_stats

    stats = user.horizon_stats.group_by{|x| Date.parse(x['begin']).to_date}.map do |day, entities|
      {
        'day'    => day.to_s,
        'length' => entities.map{|e| (DateTime.parse(e['end']).to_i - DateTime.parse(e['begin']).to_i)/60}.inject(:+)
      }
    end

    return @horizon_sessions_stats = {data: stats}
  end

  def horizon_apps_stats(user=current_user)
    return @horizon_apps_stats if @horizon_apps_stats

    stats = user.horizon_stats.group_by{|x| x['title']}.map do |title, entities|
      {
        'type'   => title,
        'number' => entities.length
      }
    end
    return @horizon_apps_stats = {data: stats}
  end

  def workspace_apps_stats(user=current_user)
    return @workspace_apps_stats if @workspace_apps_stats

    stats = user.workspace_stats.group_by{|x| x['title']}.map do |title, entities|
      {
        'type'   => title,
        'number' => entities.length
      }
    end
    return @workspace_apps_stats = {data: stats}
  end

  def workspace_activity_stats(user=current_user)
    return @workspace_activity_stats if @workspace_activity_stats

    kinds = {}
    stats = user.workspace_stats.group_by{|x| Date.parse(x['begin']).to_date}.map do |day, entities|
      result = { 'day' => day.to_s }
      entities.group_by{|x| x['title']}.each do |t,xs|
        key = t.gsub(/[-\.\s]+/,'').downcase

        result[key] = xs.length
        kinds[key]  = t
      end
      result
    end

    return @workspace_activity_stats = {data: stats, kinds: kinds}
  end

end