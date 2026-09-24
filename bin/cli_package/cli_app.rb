require "tty-prompt"
require "net/http"
require "json"
require "uri"
require_relative "definitions"

class SpendSmartCLI
  def initialize(prompt: TTY::Prompt.new(interrupt: :exit))
    @prompt = prompt
  end

  def run
    draw_header("Welcome Screen")

    action = @prompt.select("ACCOUNT:", {
      "Select existing account" => :select_account,
      "Create new account" => :create_account
    })

    if action == :select_account
      @account = select_account
    else
      @account = create_account
      sleep 1
    end

    dashboard
  end

  private

  def dashboard
    loop do
      draw_header("Dashboard for #{@account["name"]}")

      selection = @prompt.select("Choose an option:", {
        "Create Expense" => :create_exp,
        "View All Expenses" => :view_all,
        "Create a Budget" => :create_budget,
        "View Expenses by Month" => :date_filter,
        "View Expenses by Category" => :category_filter
      })

      case selection
      when :create_exp
        expense = create_expense(@account["id"])
      when :view_all
        view_all_expenses
      when :create_budget
        create_budget
      when :date_filter
        filter_by_month
      when :category_filter
        filter_by_category
      end
    end
  end

  def draw_header(screen_title)
    print "\e[H\e[2J"

    puts "=================================================="
    puts "            ACCOUNT MANAGEMENT SYSTEM"
    puts "=================================================="
    puts " Instructions:"
    puts "  • Use [↑/↓] to navigate | [ENTER] to confirm"
    puts "  • Type your text and press [ENTER] when prompted"
    puts "--------------------------------------------------"
    puts " CURRENT PAGE: #{screen_title.upcase}"
    puts "--------------------------------------------------"
    puts ""
  end
end

SpendSmartCLI.new.run
