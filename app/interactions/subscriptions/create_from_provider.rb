# frozen_string_literal: true

module Subscriptions
  class CreateFromProvider < BaseOperation
    option :provider, reader: :private
    delegate :purchase_token, :active?, :end_date, :canceled_at, :transaction_id, to: :provider

    def call
      safe_call { perform }
    end

    private

    def attrs
      {
        token: provider.purchase_token,
        active: provider.active?,
        ends_at: provider.end_date,
        canceled_at: provider.canceled_at
      }
    end

    def perform
      Subscription.create!(attrs)
    end
  end
end
