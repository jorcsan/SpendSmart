require "rails_helper"

# Guards the create-path category bug: an unconditional find_or_create_by on a
# never-submitted :category_name attached a nameless category to every expense
# and discarded the one the user chose.
RSpec.describe "Assigning a category when creating an expense", type: :request do
  let(:account) { accounts(:one) }
  let(:chosen)  { categories(:one) }

  def base_attributes
    { description: "Coffee", price: 4.75, date: Date.current, account_id: account.id }
  end

  context "when a category is chosen from the dropdown" do
    it "attaches that category" do
      post expenses_url, params: { expense: base_attributes.merge(category_id: chosen.id) }

      expect(Expense.last.category).to eq(chosen)
    end

    it "does not create any extra category" do
      expect { post expenses_url, params: { expense: base_attributes.merge(category_id: chosen.id) } }
        .not_to change(Category, :count)
    end

    it "never creates a category with no name" do
      post expenses_url, params: { expense: base_attributes.merge(category_id: chosen.id) }

      expect(Category.where(name: nil)).to be_empty
    end
  end

  context "when a new category name is typed" do
    let(:attributes) { base_attributes.merge(category_id: chosen.id, category_name: "Coffee Shops") }

    it "creates the named category and uses it instead of the dropdown" do
      expect { post expenses_url, params: { expense: attributes } }
        .to change(Category, :count).by(1)

      expect(Expense.last.category.name).to eq("Coffee Shops")
    end

    it "reuses an existing category with that name rather than duplicating it" do
      Category.create!(name: "Coffee Shops")

      expect { post expenses_url, params: { expense: attributes } }
        .not_to change(Category, :count)
    end
  end

  context "when the new category field is left blank" do
    it "falls back to the chosen category" do
      post expenses_url, params: { expense: base_attributes.merge(category_id: chosen.id, category_name: "  ") }

      expect(Expense.last.category).to eq(chosen)
    end
  end
end
