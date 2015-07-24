# == Schema Information
#
# Table name: office365_instances
#
#  id            :integer          not null, primary key
#  group_name    :string
#  group_region  :string
#  client_id     :string
#  client_secret :string
#  tenant_id     :string
#  resource_id   :string
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_office365_instances_on_deleted_at  (deleted_at)
#

class Office365Instance < ActiveRecord::Base
  acts_as_paranoid

  validates :group_region, presence: true, if: lambda{ group_name.present? }

  def config_scope
    :"instance_#{id}"
  end

  def client
    raise 'Has to be saved before querying' if new_record?

    scope = config_scope
    attrs = attributes


    # Seriously, @kioru, WTF?!
    Azure::Directory.configure do
      scope(scope) do
        client_id       attrs['client_id']
        client_secret   attrs['client_secret']
        tenant_id       attrs['tenant_id']
        resource_id     attrs['resource_id']
      end
    end

    Azure::Directory::Client.new(scope)
  end

  def update_user(email, data)
    client.update_user(email, data)
  end

  def update_password(email, password)
    client.update_user(email, {
      'passwordProfile' => {
        'password' => "#{password}", 
        'forceChangePasswordNextLogin' => 'false'
      }
    })
  end

  def assign_license(email, kind="STANDARDPACK")
    binding.pry
    client.assign_license(email, kind)
  end
end
