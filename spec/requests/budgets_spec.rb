require "rails_helper"

# Ported from test/controllers/budgets_controller_test.rb. The fixtures leave
# category nil, which is the "overall budget" case the schema allows.
RSpec.describe "Budgets", type: :request do
  let(:budget) { budgets(:one) }
  let(:valid_attributes) do
    { account_id: budget.account_id, category_id: budget.category_id, max_amount: budget.max_amount }
  end

  describe "GET /budgets" do
    it "renders the list" do
      get budgets_url

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /budgets/new" do
    it "renders the form" do
      get new_budget_url

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /budgets" do
    it "creates a budget and redirects to it" do
      expect { post budgets_url, params: { budget: valid_attributes } }
        .to change(Budget, :count).by(1)

      expect(response).to redirect_to(budget_url(Budget.last))
    end
  end

  describe "GET /budgets/:id" do
    it "renders the budget" do
      get budget_url(budget)

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /budgets/:id/edit" do
    it "renders the edit form" do
      get edit_budget_url(budget)

      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /budgets/:id" do
    it "updates the budget and redirects to it" do
      patch budget_url(budget), params: { budget: valid_attributes }

      expect(response).to redirect_to(budget_url(budget))
    end
  end

  describe "DELETE /budgets/:id" do
    it "destroys the budget and redirects to the list" do
      expect { delete budget_url(budget) }
        .to change(Budget, :count).by(-1)

      expect(response).to redirect_to(budgets_url)
    end
  end
end
