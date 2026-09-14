require "rails_helper"

# US-2 and US-3 at the model level: the scopes must compose and the total must
# follow whatever is selected.
RSpec.describe "Filtering and totalling expenses", type: :model do
  let(:account)   { accounts(:one) }
  let(:other)     { accounts(:two) }
  let(:groceries) { categories(:one) }
  let(:transport) { categories(:two) }

  before { Expense.delete_all }

  def record(category:, price:, date: Date.current, acct: account, description: "Item")
    Expense.create!(description: description, price: price, date: date, account: acct, category: category)
  end

  describe ".total (US-2)" do
    it "sums the prices of the matching expenses" do
      record(category: groceries, price: 10.00)
      record(category: groceries, price: 5.50)

      expect(Expense.total).to eq(15.50)
    end

    it "is zero when nothing matches" do
      expect(Expense.total).to eq(0)
    end

    it "totals only what the relation selected" do
      record(category: groceries, price: 10.00)
      record(category: transport, price: 99.00)

      expect(Expense.for_category(groceries.id).total).to eq(10.00)
    end

    it "adds decimals exactly" do
      3.times { record(category: groceries, price: 0.10) }

      expect(Expense.total).to eq(BigDecimal("0.30"))
    end
  end

  describe ".for_category (US-3)" do
    it "returns only expenses in that category" do
      kept    = record(category: groceries, price: 10.00, description: "Apples")
      skipped = record(category: transport, price: 20.00, description: "Bus")

      expect(Expense.for_category(groceries.id)).to include(kept)
      expect(Expense.for_category(groceries.id)).not_to include(skipped)
    end

    it "returns everything when the filter is blank" do
      record(category: groceries, price: 10.00)
      record(category: transport, price: 20.00)

      expect(Expense.for_category("").count).to eq(2)
      expect(Expense.for_category(nil).count).to eq(2)
    end
  end

  describe ".in_month" do
    it "returns only expenses dated in that month" do
      inside  = record(category: groceries, price: 10.00, date: Date.new(2026, 3, 15))
      outside = record(category: groceries, price: 20.00, date: Date.new(2026, 4, 1))

      expect(Expense.in_month("2026-03")).to include(inside)
      expect(Expense.in_month("2026-03")).not_to include(outside)
    end

    it "includes the first and last day of the month" do
      first = record(category: groceries, price: 1.00, date: Date.new(2026, 3, 1))
      last  = record(category: groceries, price: 2.00, date: Date.new(2026, 3, 31))

      expect(Expense.in_month("2026-03")).to contain_exactly(first, last)
    end

    it "filters nothing rather than raising when the value is unparseable" do
      record(category: groceries, price: 10.00)

      expect { Expense.in_month("not-a-month").to_a }.not_to raise_error
      expect(Expense.in_month("not-a-month").count).to eq(1)
    end
  end

  describe "composing filters" do
    it "applies category and month together" do
      wanted = record(category: groceries, price: 10.00, date: Date.new(2026, 3, 10))
      record(category: transport, price: 20.00, date: Date.new(2026, 3, 10))
      record(category: groceries, price: 30.00, date: Date.new(2026, 4, 10))

      result = Expense.for_category(groceries.id).in_month("2026-03")

      expect(result).to contain_exactly(wanted)
    end

    it "totals the composed selection" do
      record(category: groceries, price: 10.00, date: Date.new(2026, 3, 10))
      record(category: groceries, price: 30.00, date: Date.new(2026, 4, 10))

      expect(Expense.for_category(groceries.id).in_month("2026-03").total).to eq(10.00)
    end

    it "applies the account filter alongside the others" do
      mine = record(category: groceries, price: 10.00)
      record(category: groceries, price: 40.00, acct: other)

      expect(Expense.for_account(account.id).for_category(groceries.id)).to contain_exactly(mine)
    end
  end
end
