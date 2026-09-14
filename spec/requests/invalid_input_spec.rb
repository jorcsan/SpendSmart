require "rails_helper"

# US-5: As a spender, I want to be told exactly what is wrong when I submit an
# invalid expense, category, or budget so that I can fix it instead of losing
# what I typed.
RSpec.describe "Submitting invalid input (US-5)", type: :request do
  let(:account)  { accounts(:one) }
  let(:category) { categories(:one) }

  def valid_expense_params(**overrides)
    { description: "Coffee", price: 4.75, date: Date.current,
      account_id: account.id, category_id: category.id }.merge(overrides)
  end

  describe "an expense with a blank price" do
    before { post expenses_path, params: { expense: valid_expense_params(price: "") } }

    it "does not save it" do
      expect(Expense.where(description: "Coffee")).to be_empty
    end

    it "answers 422 rather than redirecting" do
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "says what is wrong" do
      expect(response.body).to include("Price can&#39;t be blank")
    end

    it "keeps the description that was typed" do
      expect(response.body).to include('value="Coffee"')
    end

    it "keeps the category that was chosen" do
      expect(response.body).to match(/<option selected[^>]*value="#{category.id}"/)
    end
  end

  describe "an expense priced at zero or less" do
    it "rejects zero with a usable message" do
      post expenses_path, params: { expense: valid_expense_params(price: 0) }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Price must be greater than 0")
    end

    it "rejects a negative price" do
      post expenses_path, params: { expense: valid_expense_params(price: -20) }

      expect(response.body).to include("Price must be greater than 0")
    end
  end

  describe "an expense with a blank description" do
    it "says the description is required" do
      post expenses_path, params: { expense: valid_expense_params(description: "") }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Description can&#39;t be blank")
    end

    it "keeps the price that was typed" do
      post expenses_path, params: { expense: valid_expense_params(description: "", price: 4.75) }

      expect(response.body).to include('value="4.75"')
    end
  end

  describe "an expense with no category" do
    it "says a category is required" do
      post expenses_path, params: { expense: valid_expense_params(category_id: "") }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Category must exist")
    end
  end

  describe "reporting more than one problem at once" do
    it "lists every error, not just the first" do
      post expenses_path, params: { expense: valid_expense_params(description: "", price: -1) }

      expect(response.body).to include("Description can&#39;t be blank")
      expect(response.body).to include("Price must be greater than 0")
      expect(response.body).to include("2 errors")
    end
  end

  describe "editing an expense into an invalid state" do
    let(:expense) { expenses(:one) }

    it "does not save the change" do
      original = expense.price

      patch expense_path(expense), params: { expense: { price: -5 } }

      expect(expense.reload.price).to eq(original)
    end

    it "re-renders the edit form with the error" do
      patch expense_path(expense), params: { expense: { price: -5 } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Price must be greater than 0")
    end
  end

  describe "a category with a blank or duplicate name" do
    it "rejects a blank name" do
      post categories_path, params: { category: { name: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Name can&#39;t be blank")
    end

    it "rejects a name already in use" do
      expect { post categories_path, params: { category: { name: category.name } } }
        .not_to change(Category, :count)

      expect(response.body).to include("Name has already been taken")
    end
  end

  describe "a budget with an unusable limit" do
    it "rejects a blank limit" do
      post budgets_path, params: { budget: { account_id: account.id, max_amount: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Max amount can&#39;t be blank")
    end

    it "rejects a limit of zero" do
      expect { post budgets_path, params: { budget: { account_id: account.id, max_amount: 0 } } }
        .not_to change(Budget, :count)

      expect(response.body).to include("Max amount must be greater than 0")
    end
  end

  describe "a typed new-category name when something else is wrong" do
    it "is not thrown away when the form comes back" do
      post expenses_path, params: { expense: valid_expense_params(price: "", category_name: "Coffee Shops") }

      expect(response.body).to include('value="Coffee Shops"')
    end

    it "does not create the category until the expense itself is valid" do
      expect {
        post expenses_path, params: { expense: valid_expense_params(price: "", category_name: "Coffee Shops") }
      }.not_to change(Category, :count)
    end
  end
end
