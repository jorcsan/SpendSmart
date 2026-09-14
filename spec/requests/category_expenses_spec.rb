require "rails_helper"

# US-8: As a spender, I want to open a category and see only its expenses and
# their total so that I can judge whether that part of my spending is reasonable.
RSpec.describe "Opening a category (US-8)", type: :request do
  let(:account)   { accounts(:one) }
  let(:groceries) { categories(:one) }
  let(:transport) { categories(:two) }

  describe "reaching the page" do
    it "is linked from every row of the category list" do
      get categories_path

      expect(response.body).to include(category_path(groceries))
      expect(response.body).to include(category_path(transport))
    end
  end

  describe "the category page" do
    it "names the category" do
      get category_path(groceries)

      expect(response.body).to include(groceries.name)
    end

    it "lists the expenses filed under it" do
      groceries.expenses.create!(description: "Apples", price: 5.00, account: account)

      get category_path(groceries)

      expect(response.body).to include("Apples")
    end

    it "leaves out expenses belonging to other categories" do
      transport.expenses.create!(description: "Taxi fare", price: 30.00, account: account)

      get category_path(groceries)

      expect(response.body).not_to include("Taxi fare")
    end

    it "orders the expenses newest first" do
      groceries.expenses.create!(description: "Older shop", price: 10.00, date: Date.new(2026, 1, 1), account: account)
      groceries.expenses.create!(description: "Newer shop", price: 20.00, date: Date.new(2026, 8, 1), account: account)

      get category_path(groceries)

      expect(response.body.index("Newer shop")).to be < response.body.index("Older shop")
    end
  end

  describe "the total" do
    it "shows the sum of the category's expenses" do
      Expense.delete_all
      groceries.expenses.create!(description: "Apples", price: 5.00, account: account)
      groceries.expenses.create!(description: "Bread", price: 3.25, account: account)

      get category_path(groceries)

      expect(response.body).to include("$8.25")
    end

    it "does not include spending from other categories" do
      Expense.delete_all
      groceries.expenses.create!(description: "Apples", price: 5.00, account: account)
      transport.expenses.create!(description: "Taxi fare", price: 30.00, account: account)

      get category_path(groceries)

      expect(response.body).to include("$5.00")
      expect(response.body).not_to include("$35.00")
    end

    it "reports how many expenses make up the total" do
      Expense.delete_all
      groceries.expenses.create!(description: "Apples", price: 5.00, account: account)
      groceries.expenses.create!(description: "Bread", price: 3.25, account: account)

      get category_path(groceries)

      expect(response.body).to include("2 expenses")
    end
  end

  describe "a category with nothing in it" do
    it "says so instead of showing an empty list" do
      empty = Category.create!(name: "Hobbies")

      get category_path(empty)

      expect(response.body).to include("Nothing has been filed under Hobbies yet")
    end

    it "shows a zero total" do
      empty = Category.create!(name: "Hobbies")

      get category_path(empty)

      expect(response.body).to include("$0.00")
    end
  end
end
