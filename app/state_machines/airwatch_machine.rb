class AirwatchMachine < Machine
  def normalize(state)
    if @instance.user && !@instance.user.airwatch_eula_accept_date && @state == :provisioning
      :not_approved
    else
      @state
    end
  end

  def toggle
    trigger!(:toggle)

    if @state == :not_approved
      @instance.user.accept_airwatch_eula!(skip_ids: @instance.id)
      @state = :provisioning
      normalize_and_store!
    end
  end
end