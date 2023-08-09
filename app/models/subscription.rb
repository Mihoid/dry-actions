class Subscription < ApplicationRecord
  belongs_to :user
  has_many :invoices
  has_many :payment_attempts, through: :invoices
end
