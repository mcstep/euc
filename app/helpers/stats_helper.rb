module StatsHelper
  def horizon_desktops_stats(user=current_user, global: false)
    return @horizon_desktop_stats if @horizon_desktop_stats

    kinds = {}
    stats = user.horizon_stats(global: global)
      .group_by{|x| Date.parse(x['begin']).to_date}.map do |day, entities|
        result = { 'day' => day.to_s }
        entities.group_by{|x| x['title']}.each do |t,xs|
          key = t.gsub(/[-\.\s]+/,'').downcase

          result[key] = xs.length
          kinds[key]  = t
      end

    result
    end

    @horizon_desktop_stats = {data: stats, kinds: kinds}
  end

  def horizon_sessions_stats(user=current_user, global: false)
    return @horizon_sessions_stats if @horizon_sessions_stats

    stats = user.horizon_stats(global: global)
      .group_by{|x| Date.parse(x['begin']).to_date}.map do |day, entities|
        {
          'day'    => day.to_s,
          'length' => entities.map{|e| (DateTime.parse(e['end']).to_i - DateTime.parse(e['begin']).to_i)/60}.inject(:+)
        }
      end

    @horizon_sessions_stats = {data: stats}
  end

  def horizon_apps_stats(user=current_user, global: false)
    return @horizon_apps_stats if @horizon_apps_stats

    stats = user.horizon_stats(global: global)
      .group_by{|x| x['title']}.map do |title, entities|
        {
          'type'   => title,
          'number' => entities.length
        }
      end

    @horizon_apps_stats = {data: stats}
  end

  def workspace_apps_stats(user=current_user, global: false)
    return @workspace_apps_stats if @workspace_apps_stats

    stats = user.workspace_stats(global: global)
      .group_by{|x| x['title']}.map do |title, entities|
        {
          'type'   => title,
          'number' => entities.length
        }
      end

    @workspace_apps_stats = {data: stats}
  end

  def workspace_sessions_stats(user=current_user, global: false)
    return @workspace_sessions_stats if @workspace_sessions_stats

    stats = user.workspace_stats(global: global)
      .group_by{|x| Date.parse(x['begin']).to_date}.map do |day, entities|
        {
          'day'    => day.to_s,
          'length' => entities.map{|e| (DateTime.parse(e['end']).to_i - DateTime.parse(e['begin']).to_i)/60}.inject(:+)
        }
      end

    @workspace_sessions_stats = {data: stats}
  end

  def workspace_activity_stats(user=current_user, global: false)
    return @workspace_activity_stats if @workspace_activity_stats

    kinds = {}
    stats = user.workspace_stats(global: global)
      .group_by{|x| Date.parse(x['begin']).to_date}.map do |day, entities|
        result = { 'day' => day.to_s }
        entities.group_by{|x| x['title']}.each do |t,xs|
          key = t.gsub(/[-\.\s]+/,'').downcase

          result[key] = xs.length
          kinds[key]  = t
        end
        result
      end

    @workspace_activity_stats = {data: stats, kinds: kinds}
  end

  def global_horizon_desktops_stats
    return @global_horizon_desktop_stats if @global_horizon_desktop_stats

    kinds = {}
    stats = Directory.global_stats.group_by{|x| x['day']}.map do |day, entities|
      result = { 'day' => day }
      entities.group_by{|x| x['instance']}.each do |t,xs|
        key         = t.downcase
        result[key] = xs.map{|xse| xse['desktop']}.inject(:+)
        kinds[key]  = t.upcase
      end
      result
    end

    @global_horizon_desktop_stats = {data: stats, kinds: kinds}
  end

  def global_horizon_apps_stats
    return @global_horizon_apps_stats if @global_horizon_apps_stats

    kinds = {}
    stats = Directory.global_stats.group_by{|x| x['day']}.map do |day, entities|
      result = { 'day' => day }
      entities.group_by{|x| x['instance']}.each do |t,xs|
        key         = t.downcase
        result[key] = xs.map{|xse| xse['app']}.inject(:+)
        kinds[key]  = t.upcase
      end
      result
    end

    @global_horizon_apps_stats = {data: stats, kinds: kinds}
  end

  def map_stats
    return @map_stats if @map_stats

    stats = UserRequest.recent.select('COUNT(id) AS count, country').group(:country).map do |x|
      {code: x.country, name: x.country, value: x.count}
    end
  end

  def last_quarters_dates(n)
    quarters = [
      [DateTime.now.beginning_of_quarter, DateTime.now]
    ]

    n.times do |quarter|
      quarters << [quarters.last[0] - 3.months, quarters.last[0] - 1.second]
    end

    quarters.reverse
  end

  def quarter_name(date)
    index = date.month / 3
    index = index+1 if date.month % 3 != 0
    "Q#{index}"
  end

  def invitations_quarter_stats(region='global')
    @invitations_quarter_stats ||= {}

    return @invitations_quarter_stats[region] if @invitations_quarter_stats[region]

    stats = []

    last_quarters_dates(3).each do |from, to|
      actual = Invitation.where("invitations.created_at >= ? AND invitations.created_at <= ?", from, to)
      actual = actual.joins(:to_user).where(users: {home_region: region}) unless region == 'global'
      actual = actual.count

      cumulative = (stats.last.try(:[], :cumulative) || 0) + actual

      stats << {name: quarter_name(from), actual: actual, cumulative: cumulative}
    end

    @invitations_quarter_stats[region] = {data: stats}
  end

  def potential_seats_quarter_stats(region='global')
    return @potential_seats_quarter_stats if @potential_seats_quarter_stats

    stats = []

    last_quarters_dates(3).each do |from, to|
      actual = Invitation.where("invitations.created_at >= ? AND invitations.created_at <= ?", from, to)
      actual = actual.joins(:to_user).where(users: {home_region: region}) unless region == 'global'
      actual = actual.pluck(:potential_seats).compact.inject(:+) || 0

      cumulative = (stats.last.try(:[], :cumulative) || 0) + actual

      stats << {name: quarter_name(from), actual: actual, cumulative: cumulative}
    end

    @potential_seats_quarter_stats = {data: stats}
  end
end