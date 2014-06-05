class Domain < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  enum status: [:active, :inactive]
  after_initialize :set_default_status, :if => :new_record?

  def set_default_status
    self.status ||= :active
  end
end
