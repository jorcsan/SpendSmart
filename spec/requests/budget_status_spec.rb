require "rails_helper"

# The CLI asks for an account's budgets after recording an expense, so the JSON
# has to carry the derived spend figures, not just the stored limit.
RSpec.describe "Budget status over JSON", type: :request do
  let(:account)   { accounts(:one) }
  let(:other)     { accounts(:two) }
  let(:groceries) { categories(:one) }

  before { Expense.delete_all }

  def json
    JSON.parse(response.body)
  end

  it "reports spent, remaining, and exceeded for a category budget" do
    Budget.delete_all
    Budget.create!(account: account, category: groceries, max_amount: 100)
    Expense.create!(description: "Shop", price: 120, date: Date.current,
                    account: account, category: groceries)

    get budgets_path(account_id: account.id), headers: json_headers

    budget = json.first
    expect(budget["label"]).to eq("Groceries")
    expect(budget["spent"].to_f).to eq(120.0)
    expect(budget["remaining"].to_f).to eq(-20.0)
    expect(budget["exceeded"]).to be(true)
  end

  it "reports a budget that is still within its limit" do
    Budget.delete_all
    Budget.create!(account: account, category: groceries, max_amount: 100)
    Expense.create!(description: "Shop", price: 40, date: Date.current,
                    account: account, category: groceries)

    get budgets_path(account_id: account.id), headers: json_headers

    expect(json.first["exceeded"]).to be(false)
    expect(json.first["remaining"].to_f).to eq(60.0)
  end

  it "returns only the requested account's budgets" do
    Budget.delete_all
    Budget.create!(account: account, max_amount: 100)
    Budget.create!(account: other, max_amount: 999)

    get budgets_path(account_id: account.id), headers: json_headers

    expect(json.length).to eq(1)
    expect(json.first["account_id"]).to eq(account.id)
  end

  it "labels an overall budget" do
    Budget.delete_all
    Budget.create!(account: account, category: nil, max_amount: 100)

    get budgets_path(account_id: account.id), headers: json_headers

    expect(json.first["label"]).to eq("Overall")
  end
end
