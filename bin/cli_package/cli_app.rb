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
        "View Expenses by Category" => :category_filter,
        "Edit Expense" => :edit_exp,
        "Delete Expense" => :delete_exp,
        "Exit" => :exit
      })

      case selection
      when :create_exp
        create_expense(@account["id"], @prompt)
        pause
      when :view_all
        view_all_expenses(@account["id"])
        pause
      when :edit_exp
        edit_expense(@account["id"], @prompt)
        pause
      when :delete_exp
        delete_expense(@account["id"], @prompt)
        pause
      when :exit
        puts "\nGoodbye."
        break
      else
        # Create a Budget, View by Month and View by Category have no
        # definition yet, and calling a missing method raised NameError and
        # killed the whole program. Say so and return to the menu.
        not_implemented(selection)
      end
    end
  end

  def not_implemented(selection)
    puts "\n  '#{selection}' is not implemented yet."
    pause
  end

  # Hold the result on screen until the user is ready; draw_header clears it.
  def pause
    @prompt.keypress("\n  Press any key to return to the menu...")
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
