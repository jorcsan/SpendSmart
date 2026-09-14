require "rails_helper"

# Ported from test/controllers/categories_controller_test.rb.
RSpec.describe "Categories", type: :request do
  let(:category) { categories(:one) }
  # A name of its own: category names are unique, so reusing the fixture's name
  # would be rejected rather than created.
  let(:valid_attributes) { { name: "Household Supplies" } }

  describe "GET /categories" do
    it "renders the list" do
      get categories_url

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /categories/new" do
    it "renders the form" do
      get new_category_url

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /categories" do
    it "creates a category and redirects to it" do
      expect { post categories_url, params: { category: valid_attributes } }
        .to change(Category, :count).by(1)

      expect(response).to redirect_to(category_url(Category.last))
    end
  end

  describe "GET /categories/:id" do
    it "renders the category" do
      get category_url(category)

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /categories/:id/edit" do
    it "renders the edit form" do
      get edit_category_url(category)

      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /categories/:id" do
    it "updates the category and redirects to it" do
      patch category_url(category), params: { category: valid_attributes }

      expect(response).to redirect_to(category_url(category))
    end
  end

  describe "DELETE /categories/:id" do
    # categories(:two) is used here because categories(:one) has expenses
    # attached through the fixtures, and the foreign key blocks the delete.
    it "destroys a category with no expenses and redirects to the list" do
      empty_category = Category.create!(name: "Disposable")

      expect { delete category_url(empty_category) }
        .to change(Category, :count).by(-1)

      expect(response).to redirect_to(categories_url)
    end
  end
end
