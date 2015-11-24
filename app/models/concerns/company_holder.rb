module CompanyHolder
  extend ActiveSupport::Concern

  included do
    belongs_to :company

    accepts_nested_attributes_for :company

    before_validation do
      if @company_name
        if company = Company.named(@company_name).first
          self.company_id = company.id
          self.company.type = @company_type if @company_type.present?
        else
          self.company_attributes = {
            name: @company_name,
            type: @company_type
          }
        end
      end
    end
  end

  def company_name
    @company_name || company.try(:name)
  end

  def company_name=(value)
    @company_name = value
  end

  def company_type
    @company_type || company.try(:type)
  end

  def company_type=(value)
    @company_type = value
  end
end