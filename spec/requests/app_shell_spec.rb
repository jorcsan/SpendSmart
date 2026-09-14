require "rails_helper"

# Covers the shell that makes the app usable: a home page, navigation, and
# visible flash messages. Before this, "/" served the Rails welcome page and the
# notices the controllers set were never rendered.
RSpec.describe "Application shell", type: :request do
  describe "GET /" do
    it "serves the expense list as the home page" do
      get root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Expenses")
    end
  end

  it "renders navigation to every section" do
    get root_path

    expect(response.body).to include(expenses_path)
    expect(response.body).to include(categories_path)
    expect(response.body).to include(budgets_path)
    expect(response.body).to include(accounts_path)
  end

  it "renders the flash notice after a redirect" do
    expense = expenses(:one)

    delete expense_url(expense)
    follow_redirect!

    expect(response.body).to include("Expense was successfully destroyed.")
  end
end
