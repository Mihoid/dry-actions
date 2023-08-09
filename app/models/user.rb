class User < ApplicationRecord
  has_many :subscriptions
  has_many :invoices, through: :subscriptions
  has_many :payment_attempts, through: :invoices
end
