module WebApi
  module V1
    module Subscriptions
      class FromAndroidProvider < BaseAction
        Contract = Dry::Validation::Contract.build do
          params do
            required(:provider).filled(Types.Instance(Provider))
            required(:user).filled(Types::String)
            optional(:session).filled(Types.Instance(Session))
          end
        end

        option :contract, reader: :private, default: proc { Contract }
        delegate :purchase_token, :active?, :end_date, :canceled_at, to: :provider

        def call
          subscription = yield create_subscription
          invoice = yield create_invoice(subscription)

          Success(invoice_id: invoice.id, payment_widget: payment_widget)
        end

        private

        def create_subscription
          attrs = {
            token: purchase_token,
            active: active?,
            ends_at: end_date,
            canceled_at: canceled_at
          }
          ::Subscriptions::Create.call(attrs)
        end

        def create_invoice(subscription)
          attrs = {
            subscription: subscription,
          }.compact

          Invoices::Create.call(attrs)
        end
      end
    end
  end
end
