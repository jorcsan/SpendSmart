class Budget < ApplicationRecord
  belongs_to :account
  # A budget with no category is the account's overall spending limit.
  belongs_to :category, optional: true

  # US-5. A limit of zero or less cannot be exceeded meaningfully, so it would
  # make the over-budget warning nonsense rather than strict.
  validates :max_amount, presence: true, numericality: { greater_than: 0 }

  scope :for_account, ->(account_id) { where(account_id: account_id) if account_id.present? }

  # What has been spent against this limit: everything on the account for an
  # overall budget, or just one category's expenses for a category budget.
  def spent
    expenses_in_scope.total
  end

  def remaining
    max_amount - spent
  end

  def exceeded?
    spent > max_amount
  end

  # How the budget is named on screen. A category budget is called after its
  # category; the one with no category covers the whole account.
  def label
    category&.name || "Overall"
  end

  private

    def expenses_in_scope
      account.expenses.for_category(category_id)
    end
end
