require "rails_helper"

RSpec.describe Budget, type: :model do
  let(:account)   { accounts(:one) }
  let(:other)     { accounts(:two) }
  let(:groceries) { categories(:one) }
  let(:transport) { categories(:two) }

  before { Expense.delete_all }

  def spend(amount, category: groceries, on: account)
    Expense.create!(description: "Item", price: amount, date: Date.current,
                    account: on, category: category)
  end

  describe "a category budget" do
    let(:budget) { Budget.create!(account: account, category: groceries, max_amount: 100) }

    it "counts only that category's spending" do
      spend(30, category: groceries)
      spend(500, category: transport)

      expect(budget.spent).to eq(30)
    end

    it "ignores other accounts' spending in the same category" do
      spend(30, category: groceries)
      spend(500, category: groceries, on: other)

      expect(budget.spent).to eq(30)
    end

    it "reports what is left" do
      spend(30)

      expect(budget.remaining).to eq(70)
    end

    it "is not exceeded below the limit" do
      spend(99.99)

      expect(budget).not_to be_exceeded
    end

    it "is not exceeded exactly at the limit" do
      spend(100)

      expect(budget).not_to be_exceeded
      expect(budget.remaining).to eq(0)
    end

    it "is exceeded one cent over" do
      spend(100.01)

      expect(budget).to be_exceeded
      expect(budget.remaining).to eq(BigDecimal("-0.01"))
    end

    it "is named after its category" do
      expect(budget.label).to eq("Groceries")
    end

    it "spends nothing when the account has no expenses" do
      expect(budget.spent).to eq(0)
      expect(budget).not_to be_exceeded
    end
  end

  describe "an overall budget" do
    let(:budget) { Budget.create!(account: account, category: nil, max_amount: 100) }

    it "counts spending across every category" do
      spend(30, category: groceries)
      spend(45, category: transport)

      expect(budget.spent).to eq(75)
    end

    it "is exceeded once the combined total passes the limit" do
      spend(60, category: groceries)
      spend(60, category: transport)

      expect(budget).to be_exceeded
    end

    it "is labelled Overall" do
      expect(budget.label).to eq("Overall")
    end
  end

  describe ".for_account" do
    it "returns only that account's budgets" do
      mine = Budget.create!(account: account, max_amount: 100)
      Budget.create!(account: other, max_amount: 200)

      expect(Budget.for_account(account.id)).to include(mine)
      expect(Budget.for_account(account.id).count).to eq(Budget.where(account: account).count)
    end

    it "returns everything when no account is given" do
      expect(Budget.for_account(nil).count).to eq(Budget.count)
    end
  end
end
