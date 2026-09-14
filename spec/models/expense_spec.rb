require "rails_helper"

RSpec.describe Expense, type: :model do
  let(:account)  { accounts(:one) }
  let(:category) { categories(:one) }

  def build_expense(**overrides)
    described_class.new({ description: "Coffee", price: 4.75, account: account, category: category }.merge(overrides))
  end

  describe "defaulting the date (US-1)" do
    it "uses today when no date is given" do
      expense = build_expense

      expense.save!

      expect(expense.date).to eq(Date.current)
    end

    it "uses today when the date is submitted blank" do
      expense = build_expense(date: nil)

      expense.save!

      expect(expense.date).to eq(Date.current)
    end

    it "keeps a date the user did supply" do
      expense = build_expense(date: Date.new(2026, 1, 15))

      expense.save!

      expect(expense.date).to eq(Date.new(2026, 1, 15))
    end

    it "does not overwrite the date when an existing expense is updated" do
      expense = build_expense(date: Date.new(2026, 1, 15))
      expense.save!

      expense.update!(description: "Tea")

      expect(expense.date).to eq(Date.new(2026, 1, 15))
    end
  end

  describe ".recent_first" do
    # Asserts relative order rather than .first, because the fixtures already
    # contain expenses whose dates would otherwise win.
    it "orders a newer expense ahead of an older one" do
      older = build_expense(date: Date.new(2026, 1, 1))
      newer = build_expense(date: Date.new(2026, 6, 1))
      older.save!
      newer.save!

      ordered = described_class.recent_first.to_a

      expect(ordered.index(newer)).to be < ordered.index(older)
    end

    it "puts an expense recorded today at the top of the list" do
      today = build_expense(date: Date.current)
      today.save!

      expect(described_class.recent_first.first).to eq(today)
    end
  end
end
