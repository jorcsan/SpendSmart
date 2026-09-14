require "rails_helper"

# US-5: As a spender, I want to delete an expense so that I can remove one I
# recorded by accident.
RSpec.describe "Deleting an expense (US-5)", type: :request do
  let(:expense) { expenses(:one) }

  describe "the delete control" do
    it "appears on the expense list" do
      get expenses_path

      expect(response.body).to include("Delete")
    end

    it "asks for confirmation before deleting" do
      get expenses_path

      expect(response.body).to include("turbo-confirm")
    end

    it "also asks for confirmation on the expense page" do
      get expense_path(expense)

      expect(response.body).to include("turbo-confirm")
    end
  end

  describe "deleting" do
    it "removes the expense" do
      expect { delete expense_path(expense) }
        .to change(Expense, :count).by(-1)
    end

    it "no longer shows it in the list" do
      description = expense.description
      delete expense_path(expense)

      get expenses_path

      expect(response.body).not_to include(description)
    end

    it "confirms the deletion" do
      delete expense_path(expense)
      follow_redirect!

      expect(response.body).to include("Expense was successfully destroyed.")
    end

    it "leaves the category it belonged to in place" do
      category = expense.category

      delete expense_path(expense)

      expect(Category.exists?(category.id)).to be(true)
    end
  end
end
