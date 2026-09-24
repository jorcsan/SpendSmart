json.extract! budget, :id, :max_amount, :account_id, :created_at, :updated_at
# Derived values the CLI and any other client would otherwise each recompute.
json.category_id budget.category_id
json.label budget.label
json.spent budget.spent
json.remaining budget.remaining
json.exceeded budget.exceeded?
json.url budget_url(budget, format: :json)
