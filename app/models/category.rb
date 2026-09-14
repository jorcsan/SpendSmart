class Category < ApplicationRecord
  has_many :expenses, dependent: :destroy
  has_many :budgets, dependent: :destroy

  # US-5. Case-insensitive so "Groceries" and "groceries" cannot both exist -
  # two categories a user reads as the same one would split their totals.
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # US-8: what this category has cost in total. Summed in the database rather
  # than by loading every expense, so it stays cheap as the history grows.
  # Returns 0 for a category with no expenses, never nil.
  def total_spent
    expenses.sum(:price)
  end
end
