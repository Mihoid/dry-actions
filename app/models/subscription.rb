class Subscription < ApplicationRecord
  APPLE_PLATFORM = 'apple'
  GOOGLE_PLATFORM = 'google'

  belongs_to :user
  has_many :invoices
  has_many :payment_attempts, through: :invoices
end
