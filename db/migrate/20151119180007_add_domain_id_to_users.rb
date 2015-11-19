class AddDomainIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :domain_id, :integer

    User.includes(:received_invitation).where(registration_code_id: nil, invitations: {id: nil}).each do |u|
      u.domain_id = Domain.where(name: u.email.split('@', 2)).order('id DESC').first.try(:id)
      u.save!
    end
  end
end
