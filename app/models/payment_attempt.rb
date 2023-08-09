class PaymentAttempt < ApplicationRecord
  belongs_to :invoice
  belongs_to :subscription, through: :invoice
  belongs_to :user, through: :subscription
end
