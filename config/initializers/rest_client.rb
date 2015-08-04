module RestClient
  class Request
    def execute_with_logging(&block)
      Rails.logger.tagged("RestClient") do
        Rails.logger.info("#{method.try(:upcase)} #{url.inspect} #{headers.inspect if headers.present?} #{payload.inspect if payload.present?}")

        begin
          result = execute_without_logging
          Rails.logger.info "#{result.code}\n#{result.body}"
          return result
        rescue RestClient::Exception => e
          Rails.logger.warn "#{e.response.code}\n#{e.response.body}"
          raise e
        end
      end
    end

    alias_method_chain :execute, :logging
  end
end