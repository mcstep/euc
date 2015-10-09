module StatsProvider extend ActiveSupport::Concern
  included do
    scope :today,         lambda{ where("created_at > ?", DateTime.now.beginning_of_day) }
    scope :last_week,     lambda{ where("created_at > ?", DateTime.now.beginning_of_week) }
    scope :last_month,    lambda{ where("created_at > ?", DateTime.now.beginning_of_month) }
    scope :last_quarter,  lambda{ where("created_at > ?", DateTime.now.beginning_of_quarter) }
  end
end