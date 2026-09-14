class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[ show edit update destroy ]

  # GET /expenses or /expenses.json
  def index
    # US-3: the filters are model scopes, so they chain and a blank one drops
    # out. The controller only reads params and hands them over.
    @expenses = Expense.for_account(params[:account_id])
                       .for_category(params[:category_id])
                       .in_month(params[:month])
                       .recent_first

    @total = @expenses.total
    @categories = Category.order(:name)
  end

  # GET /expenses/1 or /expenses/1.json
  def show
  end

  # GET /expenses/new
  def new
    @expense = Expense.new(date: Date.current)
  end

  # GET /expenses/1/edit
  def edit
  end

  # POST /expenses or /expenses.json
  def create
    @expense = Expense.new(expense_params)

    # A typed category name wins over the dropdown, so a user can file an
    # expense under a category that does not exist yet. Blank is the normal
    # case: overriding unconditionally would discard the chosen category_id and
    # attach a nameless one instead.
    @expense.category = find_or_initialize_category if new_category_name.present?

    respond_to do |format|
      if @expense.save
        format.html { redirect_to @expense, notice: "Expense was successfully created." }
        format.json { render :show, status: :created, location: @expense }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @expense.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /expenses/1 or /expenses/1.json
  def update
    respond_to do |format|
      if @expense.update(expense_params)
        format.html { redirect_to @expense, notice: "Expense was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @expense }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @expense.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /expenses/1 or /expenses/1.json
  def destroy
    @expense.destroy!

    respond_to do |format|
      format.html { redirect_to expenses_path, notice: "Expense was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense
      @expense = Expense.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def expense_params
      params.expect(expense: [ :description, :price, :date, :account_id, :category_id ])
    end

    # Optional free-text field for naming a category that does not exist yet.
    # Kept out of expense_params because it is not an Expense attribute.
    def new_category_name
      params.dig(:expense, :category_name)
    end

    # Initialized rather than created: a new category is only worth keeping if
    # the expense it was typed for actually saves. Active Record persists the
    # unsaved category as part of saving the expense, and leaves it untouched
    # when validation fails.
    def find_or_initialize_category
      Category.find_or_initialize_by(name: new_category_name.strip)
    end
end
