require "rails_helper"

RSpec.describe Category, type: :model do
  let(:account) { accounts(:one) }

  describe "#total_spent (US-8)" do
    it "sums the prices of its expenses" do
      category = Category.create!(name: "Books")
      category.expenses.create!(description: "Novel", price: 12.50, account: account)
      category.expenses.create!(description: "Textbook", price: 87.25, account: account)

      expect(category.total_spent).to eq(99.75)
    end

    it "returns zero for a category with no expenses" do
      category = Category.create!(name: "Unused")

      expect(category.total_spent).to eq(0)
    end

    it "ignores expenses filed under other categories" do
      category = Category.create!(name: "Books")
      other    = Category.create!(name: "Music")
      category.expenses.create!(description: "Novel", price: 12.50, account: account)
      other.expenses.create!(description: "Album", price: 9.99, account: account)

      expect(category.total_spent).to eq(12.50)
    end

    it "adds decimal amounts exactly" do
      category = Category.create!(name: "Cents")
      3.times { category.expenses.create!(description: "Snack", price: 0.10, account: account) }

      # 0.1 three times is 0.30000000000000004 in binary floating point; the
      # column is decimal so this must come back exact.
      expect(category.total_spent).to eq(BigDecimal("0.30"))
    end
  end
end
