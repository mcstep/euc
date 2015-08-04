module UserSession
  extend ActiveSupport::Concern

  def self.get_user_id(request)
    request.cookie_jar.encrypted[ Rails.application.config.session_options[:key] ]['user_id']
  end

  def self.tag_user(user_id, &block)
    user_id = user_id.id if user_id.is_a?(User)
    user_id = get_user_id(user_id) if user_id.is_a?(ActionDispatch::Request)
    result  = '#' + (user_id || '?').to_s

    if block_given?
      Rails.logger.tagged(result){ yield }
    else
      return result
    end
  end

  class Constraint
    def initialize(policy_action)
      @policy_action = policy_action
    end

    def matches?(request)
      return true if Rails.env.development?

      user_id = UserAuthentication.extract_user_id(request)
      user_id && User.find(user_id).policy.send(@policy_action)
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