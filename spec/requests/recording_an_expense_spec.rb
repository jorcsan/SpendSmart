require "rails_helper"

# US-1: As a spender, I want to record a new expense with a price, a
# description, and a category so that I have a complete record of what I spent.
RSpec.describe "Recording an expense (US-1)", type: :request do
  let(:account)  { accounts(:one) }
  let(:category) { categories(:one) }

  describe "the new-expense form" do
    it "offers price, description, category, and date" do
      get new_expense_path

      expect(response.body).to include("expense[description]")
      expect(response.body).to include("expense[price]")
      expect(response.body).to include("expense[category_id]")
      expect(response.body).to include("expense[date]")
    end

    it "pre-fills the date field itself with today" do
      get new_expense_path

      # Asserts the input's value, not merely that today's date appears
      # somewhere on the page.
      expect(response.body).to match(/<input value="#{Date.current}"[^>]*name="expense\[date\]"/)
    end
  end

  describe "submitting a valid expense" do
    let(:attributes) do
      { description: "Weekly groceries", price: 84.20, date: Date.current,
        account_id: account.id, category_id: category.id }
    end

    it "saves it" do
      expect { post expenses_path, params: { expense: attributes } }
        .to change(Expense, :count).by(1)
    end

    it "records the price, description, and category that were entered" do
      post expenses_path, params: { expense: attributes }

      expense = Expense.last
      expect(expense.description).to eq("Weekly groceries")
      expect(expense.price).to eq(84.20)
      expect(expense.category).to eq(category)
    end

    it "shows it in the expense list afterwards" do
      post expenses_path, params: { expense: attributes }

      get expenses_path

      expect(response.body).to include("Weekly groceries")
    end

    it "confirms the expense was created" do
      post expenses_path, params: { expense: attributes }
      follow_redirect!

      expect(response.body).to include("Expense was successfully created.")
    end
  end

  describe "leaving the date blank" do
    it "files the expense under today" do
      post expenses_path, params: { expense: {
        description: "Coffee", price: 4.75, date: "",
        account_id: account.id, category_id: category.id
      } }

      expect(Expense.last.date).to eq(Date.current)
    end
  end

  describe "the expense list" do
    it "shows category and account names rather than row ids" do
      post expenses_path, params: { expense: {
        description: "Bus pass", price: 25.00, account_id: account.id, category_id: category.id
      } }

      get expenses_path

      expect(response.body).to include(category.name)
      expect(response.body).to include(account.name)
    end

    it "tells the user when there is nothing recorded yet" do
      Expense.delete_all

      get expenses_path

      expect(response.body).to include("No expenses yet")
    end
  end
end
