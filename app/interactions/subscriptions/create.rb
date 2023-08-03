# frozen_string_literal: true

module Subscriptions
  class Create < BaseOperation
    option :purchase_token, Types::Subscription, reader: :private
    option :active?, Types::Subscription, reader: :private
    option :end_date, Types::Subscription, reader: :private
    option :canceled_at, Types::Subscription, reader: :private

    def call
      safe_call { perform }
    end

    private

    def perform
      Invoice.create!(
        subscription: subscription
      )
    end
  end
end
