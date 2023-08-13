module WebApi
  module V1
    module Subscriptions
      class CreateAction < BaseAction
        Contract = Dry::Validation::Contract.build do
          params do
            required(:type).filled(Types::String)
            required(:google_subscription_id).filled(Types::String)
            required(:purchase_token).filled(:Types::String)
            required(:apple_receipt).filled(:Types::String)
            required(:duration).filled(:integer)
            required(:start_offset).filled(:integer)
            required(:end_offset).filled(:integer)
          end

          # validate :duration_eq_offset_diff
          #
          # def duration_eq_offset_diff
          #   errors.add(:base, :offset_incorrect) if duration == end_offset - start_offset
          # end
          #
          # ————>>>> validation from model
          rule(:duration) do
            key.failure('duration incorrect') unless values[:duration] == values[:end_offset] - values[:start_offset]
          end
        end

        option :contract, reader: :private, default: proc { Contract }

        # ——— >>>> method from model
        # def prolong_or_cancel
        #   Api::Subscriptions::Prolong.new(self).call! if ends_at.between? Time.current, 1.hour.from_now
        #   return unless ends_at < grace_period.days.ago
        #
        #   update! canceled_at: Time.zone.now, active: false, cancel_reason: 'подписка не оплачена'
        # end

        # ——— >>>> before save callback from model
        # before_save :set_price_in_rubles
        #
        # def set_price_in_rubles
        #   self.price_currency = 'RUB'
        # end

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
          Maybe { invoice&.subscription }.bind { prolong_or_cancel(_1) }.or do
            subscription = create_subscription
            bind_subscription_for_invoice(invoice, subscription)
            subscription
          end
        end

        def prolong(subscription) # ———>>> code from model
          Subscriptions::Prolong.call(subscription)
        end

        def process_invoice
          yield find_invoice.bind { Invoices::CreatePaymentAttempt.call(_1) }.or { build_invoice }
        end

        def find_invoice
          Maybe { user.invoices.find_by(transaction_id: transaction_id)}.to_result
        end

        def create_subscription
          case params[:type]
          when 'apple'
            ::Subscriptions::CreateFromAppleProvider.new(params[:apple_receipt])
          when 'android'
            ::Subscriptions::CreateFromAndroidProvider.call(provider)
          end
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
