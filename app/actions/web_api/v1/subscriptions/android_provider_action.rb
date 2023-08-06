module WebApi
  module V1
    module Subscriptions
      class AndroidProviderAction < BaseAction
        Contract = Dry::Validation::Contract.build do
          params do
            required(:provider)
            required(:user).filled(Types.Instance(User))
            optional(:session).filled(Types.Instance(Session))
          end
        end

        option :contract, reader: :private, default: proc { Contract }

        def call
          invoice = yield process_invoice
          yield process_subscription(invoice)

          Success(invoice_id: invoice.id, payment_widget: payment_widget)
        end

        private

        def process_subscription(invoice)
          Maybe { invoice&.subscription }.or do
            subscription = create_subscription
            bind_subscription_for_invoice(invoice, subscription)
            subscription
          end
        end

        def process_invoice
          yield find_invoice.bind { Invoices::CreatePaymentAttempt.call(_1) }.or { build_invoice }
        end

        def find_invoice
          Maybe { user.invoices.find_by(transaction_id: transaction_id)}.to_result
        end

        def create_subscription
          ::Subscriptions::CreateFromProvider.call(provider)
        end

        def bind_subscription_for_invoice(invoice, subscription)
          Try { invoice.update(subscription: subscription) }
        end

        def build_invoice
          Invoice.build(attrs)
        end
      end
    end
  end
end
