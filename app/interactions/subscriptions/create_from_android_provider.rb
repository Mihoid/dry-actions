# frozen_string_literal: true

module Subscriptions
  class CreateFromAndroidProvider < BaseInteractor
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

    def perform #————>>>> before_save
      Subscription.create!(attrs.merge(price_currency: 'RUB'))
    end
  end
end
