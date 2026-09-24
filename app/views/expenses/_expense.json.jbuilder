json.extract! expense, :id, :description, :price, :date, :account_id, :category_id, :created_at, :updated_at
# Names as well as ids: the CLI lists expenses for the user to pick from, and
# a bare category_id means nothing on screen.
json.category_name expense.category&.name
json.account_name expense.account&.name
json.url expense_url(expense, format: :json)
