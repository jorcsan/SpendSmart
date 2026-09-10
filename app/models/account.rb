class Account < Application
    has_many :expenses
    has_one :budget
end
