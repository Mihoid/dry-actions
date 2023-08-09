# frozen_string_literal: true

module WebApi
  module V1
    class SubscriptionsController < WebApi::BaseController
      before_action :fetch_provider, only: :from_android_provider

      def create
        Subscriptions::CreateAction.call(params)
          .either(
            ->(subscription) { render json: subscription },
            ->(error) { error }
          )
      end

      private

      def fetch_provider
        @provider =
          case params[:type]
          when 'apple'
            Api::Subscriptions::Providers::AppleSubscriptionProvider.new(params[:receipt])
          when 'android'
            Api::Subscriptions::Providers::AndroidIapSubscriptionProvider.new(
              google_subscription_id: params[:google_subscription_id],
              purchase_token: params[:purchase_token]
            )
          end
      end
    end
  end
end
