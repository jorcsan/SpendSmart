class Category < ApplicationRecord
    has_many :expenses
    has_one :budget
end
