class RegCode < ActiveRecord::Base
  validates_uniqueness_of :code

  def code=(val)
    write_attribute(:code, val.downcase)
  end
end
