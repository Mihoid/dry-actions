class Invoice < ApplicationRecord
  belongs_to :subscription
  belongs_to :user, through: subscription

  has_many :payment_attempts
end
