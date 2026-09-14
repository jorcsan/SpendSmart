require "rails_helper"

# US-2: see all my expenses in one list with a running total.
# US-3: filter that list by category, with the total following the filter.
RSpec.describe "The expense list (US-2, US-3)", type: :request do
  let(:account)   { accounts(:one) }
  let(:groceries) { categories(:one) }
  let(:transport) { categories(:two) }

  before { Expense.delete_all }

  def record(category:, price:, description:, date: Date.current)
    Expense.create!(description: description, price: price, date: date,
                    account: account, category: category)
  end

  describe "the running total (US-2)" do
    it "shows the sum of every expense" do
      record(category: groceries, price: 84.20, description: "Weekly shop")
      record(category: transport, price: 25.00, description: "Bus pass")

      get expenses_path

      expect(response.body).to include("$109.20")
    end

    it "reports how many expenses make it up" do
      record(category: groceries, price: 10.00, description: "Apples")
      record(category: transport, price: 25.00, description: "Bus pass")

      get expenses_path

      expect(response.body).to include("2 expenses")
    end

    it "shows zero when nothing has been recorded" do
      get expenses_path

      expect(response.body).to include("$0.00")
    end
  end

  describe "the category filter (US-3)" do
    before do
      record(category: groceries, price: 84.20, description: "Weekly shop")
      record(category: transport, price: 25.00, description: "Bus pass")
    end

    it "offers a category selector above the list" do
      get expenses_path

      expect(response.body).to include("All categories")
      expect(response.body).to include(groceries.name)
      expect(response.body).to include(transport.name)
    end

    it "shows only expenses in the chosen category" do
      get expenses_path, params: { category_id: groceries.id }

      expect(response.body).to include("Weekly shop")
      expect(response.body).not_to include("Bus pass")
    end

    it "updates the total to match the filter" do
      get expenses_path, params: { category_id: groceries.id }

      expect(response.body).to include("$84.20")
      expect(response.body).not_to include("$109.20")
    end

    it "keeps the chosen category selected after the page reloads" do
      get expenses_path, params: { category_id: groceries.id }

      expect(response.body).to match(/<option selected[^>]*value="#{groceries.id}"/)
    end

    it "offers a way to clear the filter" do
      get expenses_path, params: { category_id: groceries.id }

      expect(response.body).to include("Clear filter")
    end

    it "restores the full list when the filter is cleared" do
      get expenses_path, params: { category_id: "" }

      expect(response.body).to include("Weekly shop")
      expect(response.body).to include("Bus pass")
      expect(response.body).to include("$109.20")
    end

    it "says so when a category has nothing in it, rather than looking broken" do
      empty = Category.create!(name: "Hobbies")

      get expenses_path, params: { category_id: empty.id }

      expect(response.body).to include("Nothing recorded in this category")
    end

    it "does not offer to clear a filter that is not applied" do
      get expenses_path

      expect(response.body).not_to include("Clear filter")
    end
  end

  describe "an unparseable month in the URL" do
    it "does not blow up" do
      record(category: groceries, price: 10.00, description: "Apples")

      get expenses_path, params: { month: "nonsense" }

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Apples")
    end
  end
end
