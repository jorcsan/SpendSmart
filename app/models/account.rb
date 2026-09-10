class Account < ApplicationRecord
    has_many :expenses, dependent: :destroy
    has_one :budget, dependent: :destroy
end
