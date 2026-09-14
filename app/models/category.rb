class Category < ApplicationRecord
  has_many :expenses, dependent: :destroy
  has_many :budgets, dependent: :destroy

  # US-8: what this category has cost in total. Summed in the database rather
  # than by loading every expense, so it stays cheap as the history grows.
  # Returns 0 for a category with no expenses, never nil.
  def total_spent
    expenses.sum(:price)
  end
end
