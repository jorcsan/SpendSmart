require "rails_helper"

# Ported from test/controllers/expenses_controller_test.rb. These cover the
# happy path of every CRUD action; sad-path coverage arrives with the model
# validations (issue #12).
RSpec.describe "Expenses", type: :request do
  let(:expense) { expenses(:one) }
  let(:valid_attributes) do
    {
      description: expense.description,
      price: expense.price,
      date: expense.date,
      account_id: expense.account_id,
      category_id: expense.category_id
    }
  end

  describe "GET /expenses" do
    it "renders the list" do
      get expenses_url

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /expenses/new" do
    it "renders the form" do
      get new_expense_url

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /expenses" do
    it "creates an expense and redirects to it" do
      expect { post expenses_url, params: { expense: valid_attributes } }
        .to change(Expense, :count).by(1)

      expect(response).to redirect_to(expense_url(Expense.last))
    end
  end

  describe "GET /expenses/:id" do
    it "renders the expense" do
      get expense_url(expense)

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /expenses/:id/edit" do
    it "renders the edit form" do
      get edit_expense_url(expense)

      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /expenses/:id" do
    it "updates the expense and redirects to it" do
      patch expense_url(expense), params: { expense: valid_attributes }

      expect(response).to redirect_to(expense_url(expense))
    end
  end

  describe "DELETE /expenses/:id" do
    it "destroys the expense and redirects to the list" do
      expense_to_delete = expense

      expect { delete expense_url(expense_to_delete) }
        .to change(Expense, :count).by(-1)

      expect(response).to redirect_to(expenses_url)
    end
  end
end
