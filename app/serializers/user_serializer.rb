class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :company_name,
    :job_title, :home_region, :total_invitations, :invitations_used, :created_at, :can_see_reports,
    :can_see_opportunities, :can_edit_services

  has_many :user_integrations
  belongs_to :profile

  url [:api, :user]
end
