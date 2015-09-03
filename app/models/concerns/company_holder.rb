module CompanyHolder
  extend ActiveSupport::Concern

  included do
    belongs_to :company

    accepts_nested_attributes_for :company
  end

  def company_name
    company.try :name
  end

  def company_name=(value)
    value = value.strip

    if company = Company.named(value).first
      self.company_id = company.id
    else
      self.company_attributes = {name: value}
    end
  end
end