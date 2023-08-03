# frozen_string_literal: true

# @note Used to validate input parameters and operations calls
#   Called only in a controller
#   Returns result monad with data to render
module WebApi
  module V1
    class BaseAction < ::BaseAction
      option :current_session, Types.Instance(Session).maybe, reader: :private
      option :current_country, Types::String, reader: :private
      option :visitor_id, Types::String.maybe, reader: :private

      def perform
        @validated_params = yield validate_params

        call
      end

      private

      def current_profile
        current_session.maybe(&:profile)
      end

      def current_user
        current_session.maybe(&:user)
      end
    end
  end
end
