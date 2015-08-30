class Machine < MicroMachine
  attr_accessor :normalizer
  attr_reader   :state

  def initialize(instance, service)
    @instance   = instance
    @field      = "#{service}_status"

    super instance.send(@field)

    unless instance.deleted_at?
      unless instance.send("prohibit_#{service}")
        self.when :toggle,
          revoked:        :provisioning,
          deprovisioned:  :provisioning,
          provisioned:    :revoking,
          not_approved:   :deprovisioned
      else
        self.when :toggle, {}
      end

      self.when :approve,
        not_approved:   :provisioning

      if instance.new_record?
        self.when :prohibit,
          deprovisioned:  :deprovisioned,
          provisioning:   :deprovisioned,
          provisioned:    :deprovisioned,
          not_approved:   :deprovisioned
      else
        self.when :prohibit,
          deprovisioned:  :deprovisioned,
          provisioned:    :revoking,
          not_approved:   :deprovisioned
      end
    end

    self.when :complete_application,
      provisioning:   :provisioned,
      revoking:       :revoked,
      deprovisioning: :deprovisioned

    self.when :deprovision,
      not_approved:   :deprovisioned,
      deprovisioned:  :deprovisioned,
      provisioned:    :revoking,
      revoked:        :deprovisioning

    self.when :deprovision_automatically,
      revoking:       :deprovisioning

    self.on(:any) { normalize_and_store! }
  end

  def method_missing(name, *args)
    trigger!(name)
  end

  def complete_application
    if @instance.deleted_at? && @instance.send(@field) == :revoking
      trigger!(:deprovision_automatically)
    else
      trigger!(:complete_application)
    end
  end

  def applying?
    [:provisioning, :revoking, :deprovisioning].include? @state
  end

  def disabled?
    ![:provisioning, :provisioned, :not_approved].include? @state
  end

  def normalize_and_store!
    @state = normalize(@state) if respond_to?(:normalize)
    @instance.send :"#{@field}=", @state
  end
end