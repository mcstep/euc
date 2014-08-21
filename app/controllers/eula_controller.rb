class EulaController < ApplicationController
  def create
    inv = Invitation.find_by_recipient_username(current_user.username)
    inv.eula_accept_date = Time.now
    inv.save!

    # Call the provisioning worker
    puts "Calling airwatch provision sync.."
    AirwatchProvisionWorker.perform_async(current_user.id)
    puts "Done calling airwatch provision sync.."
    # Finished calling the provisioning worker

    redirect_to dashboard_path, notice: "Thanks! You've successfully accepted the AirWatch EULA. Your AirWatch Trial will be activated shortly."
  end

  def toggle_airwatch
    @invitation = Invitation.find_by_id(params[:id])
    user_status = true
    if @invitation.airwatch_trial == true
       @invitation.airwatch_trial = false
       @invitation.google_apps_trial = false
       # Deactivate AirWatch user
       user_status = false
    else
       @invitation.airwatch_trial = true
       @invitation.google_apps_trial = true
       # Activate AirWatch user
       user_status= true
    end
    @invitation.save!

    # Update AirWatch status if the user is already enrolled
    if !@invitation.airwatch_user_id.nil?
      puts "User #{@invitation.recipient_username} enrolled in AirWatch. Calling AirWatch to disable status"
      AirwatchUpdateWorker.perform_async(@invitation.id, user_status)
    else
      puts "User #{@invitation.recipient_username} NOT enrolled in AirWatch. Moving on!"
    end

    respond_to do |format|
      format.html { redirect_to request.referer }
      format.json { head :no_content }
    end
  end
end
