module Ghetto
  class BaseApiController < ActionController::Base
      before_filter :parse_request, :authenticate_user_from_token!
      skip_before_filter  :verify_authenticity_token

      private
          def authenticate_user_from_token!
            api_token = request.headers['HTTP_API_TOKEN']
            if !api_token.eql? ENV["API_TOKEN"]
              render nothing: true, status: :unauthorized
            end
          end

          def parse_request
            json = request.body.read
            puts "JSON: " + json
            @json = JSON.parse(json) if json && json.length >= 2#JSON.parse(request.body.read)
          end
  end
end