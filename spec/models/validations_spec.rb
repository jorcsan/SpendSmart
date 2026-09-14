require "rails_helper"

# US-5, at the model level. The request specs cover what the user sees; these
# pin the rules themselves.
RSpec.describe "Validation rules (US-5)" do
  let(:account)  { accounts(:one) }
  let(:category) { categories(:one) }

  describe Expense do
    def expense(**overrides)
      Expense.new({ description: "Coffee", price: 4.75, account: account, category: category }.merge(overrides))
    end

    it "requires a description" do
      record = expense(description: "")

      expect(record).not_to be_valid
      expect(record.errors[:description]).to include("can't be blank")
    end

    it "requires a price" do
      record = expense(price: nil)

      expect(record).not_to be_valid
      expect(record.errors[:price]).to include("can't be blank")
    end

    it "rejects a price of zero" do
      record = expense(price: 0)

      expect(record).not_to be_valid
      expect(record.errors[:price]).to include("must be greater than 0")
    end

    it "rejects a negative price" do
      record = expense(price: -12.00)

      expect(record).not_to be_valid
      expect(record.errors[:price]).to include("must be greater than 0")
    end

    it "rejects a price that is not a number" do
      record = expense(price: "free")

      expect(record).not_to be_valid
      expect(record.errors[:price]).to include("is not a number")
    end

    it "requires a category" do
      record = expense(category: nil)

      expect(record).not_to be_valid
      expect(record.errors[:category]).to include("must exist")
    end

    it "accepts a valid expense" do
      expect(expense).to be_valid
    end
  end

  describe Category do
    it "requires a name" do
      record = Category.new(name: "")

      expect(record).not_to be_valid
      expect(record.errors[:name]).to include("can't be blank")
    end

    it "rejects a duplicate name" do
      record = Category.new(name: category.name)

      expect(record).not_to be_valid
      expect(record.errors[:name]).to include("has already been taken")
    end

    it "rejects a duplicate that differs only in capitalisation" do
      record = Category.new(name: category.name.upcase)

      expect(record).not_to be_valid
      expect(record.errors[:name]).to include("has already been taken")
    end

    it "lets a category keep its own name when updated" do
      expect(category.update(name: category.name)).to be(true)
    end

    it "accepts an unused name" do
      expect(Category.new(name: "Household Supplies")).to be_valid
    end
  end

  describe Budget do
    def budget(**overrides)
      Budget.new({ max_amount: 500, account: account }.merge(overrides))
    end

    it "requires a limit" do
      record = budget(max_amount: nil)

      expect(record).not_to be_valid
      expect(record.errors[:max_amount]).to include("can't be blank")
    end

    it "rejects a limit of zero" do
      record = budget(max_amount: 0)

      expect(record).not_to be_valid
      expect(record.errors[:max_amount]).to include("must be greater than 0")
    end

    it "rejects a negative limit" do
      record = budget(max_amount: -50)

      expect(record).not_to be_valid
      expect(record.errors[:max_amount]).to include("must be greater than 0")
    end

    it "still allows an overall budget with no category" do
      expect(budget(category: nil)).to be_valid
    end
  end
end
