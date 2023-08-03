# frozen_string_literal: true

module Invoices
  class Create < BaseOperation
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
