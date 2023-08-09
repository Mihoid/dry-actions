# frozen_string_literal: true

module Invoices
  class Create < BaseInteractor
    option :subscription, Types::Subscription, reader: :private

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
