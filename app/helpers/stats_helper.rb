module StatsHelper
  def desktops_stats
    return @desktop_stats if @desktop_stats

    kinds = Set.new
    stats = current_user.stats.group_by{|x| Date.parse(x['begin']).to_date}.map do |day, entities|
      result = { 'day' => day.to_s }
      entities.group_by{|x| x['type']}.each do |t,xs|
        result[t] = xs.length
        kinds << t
      end
      result
    end

    return @desktop_stats = {data: stats, kinds: kinds}
  end

  def sessions_stats
    return @sessions_stats if @sessions_stats

    stats = current_user.stats.group_by{|x| Date.parse(x['begin']).to_date}.map do |day, entities|
      {
        'day'    => day.to_s,
        'length' => entities.map{|e| DateTime.parse(e['end']).to_i - DateTime.parse(e['begin']).to_i}.inject(:+)
      }
    end

    return @sessions_stats = {data: stats}
  end

  def apps_stats
    return @apps_stats if @apps_stats

    stats = current_user.stats.group_by{|x| x['title']}.map do |title, entities|
      {
        'type'   => title,
        'number' => entities.length
      }
    end
    return @apps_stats = {data: stats}
  end
end