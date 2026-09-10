json.extract! expense, :id, :description, :price, :date, :account_id, :category_id, :created_at, :updated_at
json.url expense_url(expense, format: :json)
