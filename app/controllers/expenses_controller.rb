class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[ show edit update destroy ]

  # GET /expenses or /expenses.json
  def index
    @expenses = Expense.all

    # list expenses within a certain account
    if params[:account_id]
      @expenses = Account.find(params[:account_id]).expenses
    end

    # list expenses within a certain category
    if params[:category_id]
      @expenses = @expenses.where(category_id: params[:category_id])
    end

    # list expenses within a certain month
    # accept a year and month as input and parse into a date value type
    if params[:month].present?
      month = Date.parse("#{params[:month]}-01")

      @expenses = @expenses.where(
        date: month.beginning_of_month..month.end_of_month
      )
    end
  end

  # GET /expenses/1 or /expenses/1.json
  def show
  end

  # GET /expenses/new
  def new
    @expense = Expense.new
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
    @expense.category = find_or_create_category if new_category_name.present?

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

    def find_or_create_category
      Category.find_or_create_by(name: new_category_name.strip)
    end
end
