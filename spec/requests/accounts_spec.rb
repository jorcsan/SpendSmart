require "rails_helper"

# Ported from test/controllers/accounts_controller_test.rb.
RSpec.describe "Accounts", type: :request do
  let(:account) { accounts(:one) }
  let(:valid_attributes) { { name: account.name } }

  describe "GET /accounts" do
    it "renders the list" do
      get accounts_url

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /accounts/new" do
    it "renders the form" do
      get new_account_url

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /accounts" do
    it "creates an account and redirects to it" do
      expect { post accounts_url, params: { account: valid_attributes } }
        .to change(Account, :count).by(1)

      expect(response).to redirect_to(account_url(Account.last))
    end
  end

  describe "GET /accounts/:id" do
    it "renders the account" do
      get account_url(account)

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /accounts/:id/edit" do
    it "renders the edit form" do
      get edit_account_url(account)

      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /accounts/:id" do
    it "updates the account and redirects to it" do
      patch account_url(account), params: { account: valid_attributes }

      expect(response).to redirect_to(account_url(account))
    end
  end

  describe "DELETE /accounts/:id" do
    # accounts(:one) owns fixture expenses and budgets; a fresh account is used
    # so the destroy is not blocked by a foreign key.
    it "destroys an account with no expenses and redirects to the list" do
      empty_account = Account.create!(name: "Disposable")

      expect { delete account_url(empty_account) }
        .to change(Account, :count).by(-1)

      expect(response).to redirect_to(accounts_url)
    end
  end
end
