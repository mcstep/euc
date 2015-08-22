namespace :db do
  namespace :import do
    task :run => [:domains, :accounts, :reg_codes, :airwatch_groups, :users]

    task :ensure => :environment do
      raise "Default profile not found" unless Profile.where(name: 'Default').any?
    end

    task :domains => :ensure do
      profile  = Profile.where(name: 'Default').first
      existing = Domain.pluck(:name)

      Upgrade::Domain.where.not(name: existing).each do |domain|
        Domain.create!(name: domain.name, profile_id: profile.id, status: domain.status, user_role: :admin)
      end
    end

    task :accounts => :ensure do
      existing = Account.pluck(:email)

      Upgrade::Account.where.not(email: existing).each do |account|
        Account.create!(account.attributes.merge(id: nil))
      end
    end

    task :reg_codes => :ensure do
      existing = RegistrationCode.pluck(:code)
      profile  = Profile.where(name: 'Default').first

      RegistrationCode.transaction do
        Upgrade::RegCode.where.not(code: existing).each do |reg_code|
          RegistrationCode.create!(
            code:                reg_code.code,
            valid_from:          reg_code.valid_from,
            valid_to:            reg_code.valid_to,
            user_validity:       reg_code.account_validity,
            total_registrations: reg_code.registrations,
            user_role:           reg_code.account_type,
            profile_id:          profile.id
          )
        end
      end
    end

    task :airwatch_groups => :ensure do
      existing = AirwatchGroup.pluck(:text_id)
      instance = Profile.where(name: 'Default').first.profile_integrations.first.integration.airwatch_instance

      AirwatchGroup.transaction do
        Upgrade::AirwatchGroup.where.not(group_id: existing).each do |ag|
          AirwatchGroup.create!(
            airwatch_instance:  instance,
            text_id:            ag.group_id,
            numeric_id:         ag.group_id_num,
            kind:               ag.group_type
          )
        end
      end
    end

    task :users => :ensure do
      existing    = User.pluck(:email)
      profile_d   = Profile.where(name: 'Default').first
      profile_a   = Profile.where(name: 'Apple').first
      users       = Upgrade::User.order(:id)
      users       = users.where.not("LOWER(email) IN (?)", existing) if existing.any?
      customs     = %w(joshi.io apple.com)

      users.includes(:invitation, invitation: [:sender, :reg_code]).find_each do |user|
        User.transaction do
          next if user.invitation.region.blank?

          profile = customs.include?(user.email.split('@').last) ? profile_a : profile_d
          integration = profile.profile_integrations.first.integration

          new_user = User.new(
            is_importing: true,
            email: user.email,
            role: user.role,
            company_name: user.company,
            first_name: user.display_name.split(' ', 2).first,
            last_name: user.display_name.split(' ', 2).last,
            job_title: user.title,
            total_invitations: user.total_invitations,
            invitations_used: user.invitations_used,
            home_region: user.invitation.region.downcase,
            profile_id: profile.id,
            airwatch_eula_accept_date: user.invitation.eula_accept_date.try(:to_date),
            skip_provisioning: true,
            integrations_username: user.username,
            integrations_expiration_date: user.invitation.expires_at,
            user_integrations_attributes: [{
              integration_id: integration.id,
              google_apps_disabled: !user.invitation.google_apps_trial,
              airwatch_disabled: !user.invitation.airwatch_trial,
              airwatch_user_id: user.invitation.airwatch_user_id,
              airwatch_admin_user_id: user.invitation.airwatch_admin_user_id
            }]
          )
          if user.invitation.reg_code
            rc = RegistrationCode.where(code: user.invitation.reg_code.code).first
            raise 'Registration code not found' if rc.blank?
            new_user.registration_code = rc
          end

          new_user['avatar'] = user.avatar
          new_user.save!

          if user.invitation.sender
            Invitation.create!(
              skip_points_management: true,
              from_user: User.where(email: user.invitation.sender.email.downcase).first,
              to_user: new_user,
              sent_at: user.invitation.created_at,
              potential_seats: user.invitation.potential_seats
            )
          end

          new_user.user_integrations.each do |ui|
            unless ui.airwatch_disabled?
              ui.airwatch_group_id = AirwatchGroup.where(text_id: ui.airwatch_group_name)
            end

            Integration::SERVICES.each do |s|
              unless ui.send("#{s}_disabled")
                ui.send("#{s}_status=", :provisioned)
              end
            end

            ui.save!
          end

          user.invitation.extensions.includes(:extendor).each do |e|
            next if e.extendor.blank?

            DirectoryProlongation.create!(
              skip_expiration_management: true,
              user_integration_id:        new_user.authentication_integration.id,
              user:                       User.where(email: e.extendor.try(:email)).first,
              reason:                     e.reason,
              expiration_date_old:        e.original_expires_at,
              expiration_date_new:        e.revised_expires_at
            )
          end
        end
      end
    end
  end
end