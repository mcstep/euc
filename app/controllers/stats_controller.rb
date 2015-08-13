class StatsController < ApplicationController
  before_action{ authorize :stat }

  def desktops
    kinds = Set.new
    stats = current_user.stats.group_by{|x| Date.parse(x['begin']).to_date}.map do |day, entities|
      result = { 'day' => day.to_s }
      entities.group_by{|x| x['type']}.each do |t,xs|
        result[t] = xs.length
        kinds << t
      end
      result
    end

    @stats = {data: stats, kinds: kinds}
  end

  def sessions
    @stats = current_user.stats.group_by{|x| Date.parse(x['begin']).to_date}.map do |day, entities|
      {
        'day'    => day.to_s,
        'length' => entities.map{|e| DateTime.parse(e['end']).to_i - DateTime.parse(e['begin']).to_i}.inject(:+)
      }
    end
    @stats = {data: @stats}
  end

  def apps
    @stats = current_user.stats.group_by{|x| x['title']}.map do |title, entities|
      {
        'type'   => title,
        'number' => entities.length
      }
    end
    @stats = {data: @stats}
  end
end
