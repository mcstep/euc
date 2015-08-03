module UserAuthentication
  extend ActiveSupport::Concern

  class Constraint
    def initialize(policy_action)
      @policy_action = policy_action
    end

    def matches?(request)
      Rails.env.development? || User.find(request.session[:user_id]).policy.send(@policy_action)
    end
  end

  def authenticate(password)
    return false unless data = authentication_integration.directory.authenticate(
      authentication_integration.username,
      password
    )
    update_from_ad!(data)

    true
  end
end