class Category < ApplicationRecord
  has_many :expenses, dependent: :destroy
  has_many :budgets, dependent: :destroy
end
