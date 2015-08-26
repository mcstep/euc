# This patch makes builder respect association-related errors
module BootstrapForm
  class FormBuilder
    def locate_error(name)
      return false if name.blank? || !object.respond_to?(:errors)

      attempt = if name.to_s.ends_with?('_id')
        object.errors[name.to_s[0...-3]]
      end

      attempt.blank? ? object.errors[name] : attempt
    end

    def has_error?(name)
      locate_error(name).present?
    end

    def get_error_messages(name)
      locate_error(name).join(', ')
    end
  end
end