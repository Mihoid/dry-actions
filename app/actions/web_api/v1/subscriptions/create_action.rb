module WebApi
  module V1
    module Subscriptions
      class CreateAction < BaseAction
        Contract = Dry::Validation::Contract.build do
          params do
            required(:type).filled(Types::String)
            required(:google_subscription_id).filled(Types::String)
            required(:purchase_token).filled(:Types::String)
          end
        end

        option :contract, reader: :private, default: proc { Contract }

        def call
          invoice = yield process_invoice
          subscription = yield process_subscription(invoice)

          Success(subscription)
        end

        private

        def provider
          @provider ||= Subscriptions::FetchAndroidProvider.call(validated_params).to_result
        end

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
          ::Subscriptions::CreateFromAndroidProvider.call(provider)
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
