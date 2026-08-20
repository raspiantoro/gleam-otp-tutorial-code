import gleam/float
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import tempo/date
import tracker/agent
import tracker/expense

pub fn main() {
  let assert Ok(catalog_agent) = agent.start()

  let assert Ok(expense_date) = date.from_string("2026-7-21")

  let create_expense =
    expense.CreateExpense(
      4.5,
      expense.category_from_string("Food"),
      expense_date,
      option.Some("Morning coffee"),
    )

  agent.add_expense(catalog_agent, create_expense)

  let create_expense =
    expense.CreateExpense(
      49.0,
      expense.category_from_string("Education"),
      expense_date,
      option.Some("Online course subscription"),
    )

  agent.add_expense(catalog_agent, create_expense)

  let create_expense =
    expense.CreateExpense(
      20.0,
      expense.category_from_string("Gift"),
      date.literal("2026-7-22"),
      option.Some("Charity donation"),
    )

  agent.add_expense(catalog_agent, create_expense)

  agent.get_all(catalog_agent)
  |> list.each(fn(expense) { io.println(string.inspect(expense)) })

  let today = expense_date |> date.get_month_year

  io.println("monthly detail: ")

  agent.monthly_detail(catalog_agent, today.month, today.year)
  |> list.each(fn(expense) { io.println(string.inspect(expense)) })

  io.println("monthly summary: ")

  let expense.Summary(total, categories_summary) =
    agent.monthly_summary(catalog_agent, today.month, today.year)

  io.println("total: " <> float.to_string(total))
  categories_summary
  |> list.each(fn(category_summary) {
    io.println(string.inspect(category_summary))
  })
}
