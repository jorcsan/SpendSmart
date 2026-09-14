class Budget < ApplicationRecord
  belongs_to :account
  # A budget with no category is the account's overall spending limit.
  belongs_to :category, optional: true

  # US-5. A limit of zero or less cannot be exceeded meaningfully, so it would
  # make the over-budget warning nonsense rather than strict.
  validates :max_amount, presence: true, numericality: { greater_than: 0 }
end
