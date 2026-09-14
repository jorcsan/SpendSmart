require "rails_helper"

# US-4: As a spender, I want to change an expense I already recorded so that I
# can correct a typo without deleting and re-entering it.
RSpec.describe "Editing an expense (US-4)", type: :request do
  let(:expense) { expenses(:one) }

  describe "reaching the edit form" do
    it "is linked from the expense list" do
      get expenses_path

      expect(response.body).to include(edit_expense_path(expense))
    end

    it "is linked from the expense page" do
      get expense_path(expense)

      expect(response.body).to include(edit_expense_path(expense))
    end
  end

  describe "the edit form" do
    it "is pre-filled with the current values" do
      get edit_expense_path(expense)

      expect(response.body).to include(expense.description)
    end

    it "pre-selects the category the expense already has" do
      get edit_expense_path(expense)

      expect(response.body).to match(/<option selected[^>]*value="#{expense.category_id}"/)
    end
  end

  describe "saving a change" do
    it "updates the price" do
      patch expense_path(expense), params: { expense: { price: 123.45 } }

      expect(expense.reload.price).to eq(123.45)
    end

    it "shows the new price in the list" do
      patch expense_path(expense), params: { expense: { price: 123.45 } }

      get expenses_path

      expect(response.body).to include("123.45")
    end

    it "confirms the update" do
      patch expense_path(expense), params: { expense: { description: "Corrected" } }
      follow_redirect!

      expect(response.body).to include("Expense was successfully updated.")
    end

    it "leaves the recorded date alone" do
      original = expense.date

      patch expense_path(expense), params: { expense: { description: "Corrected" } }

      expect(expense.reload.date).to eq(original)
    end

    it "does not create a duplicate expense" do
      expect { patch expense_path(expense), params: { expense: { price: 50 } } }
        .not_to change(Expense, :count)
    end
  end
end
