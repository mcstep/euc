class RegCode < ActiveRecord::Base
  has_many :invitation

  validates_uniqueness_of :code

  def code=(val)
    write_attribute(:code, val.downcase)
  end
end
