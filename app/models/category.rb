class Category < ApplicationRecord
  has_many :expenses, dependent: :destroy
  has_many :budgets, dependent: :destroy

  # US-5. Case-insensitive so "Groceries" and "groceries" cannot both exist -
  # two categories a user reads as the same one would split their totals.
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # US-8: what this category has cost in total. Delegates to Expense.total so
  # there is one definition of "total" in the app, not two that could drift.
  def total_spent
    expenses.total
  end
end
