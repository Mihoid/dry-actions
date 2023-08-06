# frozen_string_literal: true

module WebApi
  module V1
    class SubscriptionsController < WebApi::BaseController
      def from_android_provider
        with_action(Subscriptions::AndroidProviderAction) { |data| render json: data, status: :created }
      end

      private

      def unauthorized_entity(*)
        render json: { error: { message: 'Authorization required' } }, status: :unauthorized, adapter: false
      end

      def handle_service_failure(error)
        case error
        in Dry::Validation::Result
          render json: { error: { message: 'Error of validate parameters', **error.errors.to_hash } },
                 status: :bad_request
        in ActiveRecord::RecordNotFound
          render json: { error: { message: "#{error.model} not found" } }, status: :not_found
        else
          super(error)
        end
      end

      def error!(message:, title: nil, status: :unprocessable_entity)
        render json: { error: { message: message, title: title }.compact }, status: status
      end
    end
  end
end
