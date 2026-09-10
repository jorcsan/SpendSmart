class Account < ApplicationRecord
  has_many :expenses, dependent: :destroy
  # An account holds one budget per category plus an optional overall budget
  # (the row whose category_id is nil), so this is has_many, not has_one.
  has_many :budgets, dependent: :destroy
end
