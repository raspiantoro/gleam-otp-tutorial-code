import gleam/erlang/process
import gleam/float
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import tempo/date
import tracker/agent_process.{Add, GetAll, MonthlyDetail, MonthlySummary}
import tracker/expense

pub fn main() {
  let agent_subject = agent_process.run()

  let assert Ok(expense_date) = date.from_string("2026-7-21")

  let create_expense =
    expense.CreateExpense(
      4.5,
      expense.category_from_string("Food"),
      expense_date,
      option.Some("Morning coffee"),
    )

  process.send(agent_subject, Add(create_expense))

  let create_expense =
    expense.CreateExpense(
      49.0,
      expense.category_from_string("Education"),
      expense_date,
      option.Some("Online course subscription"),
    )

  process.send(agent_subject, Add(create_expense))

  let create_expense =
    expense.CreateExpense(
      20.0,
      expense.category_from_string("Gift"),
      date.literal("2026-7-22"),
      option.Some("Charity donation"),
    )

  process.send(agent_subject, Add(create_expense))

  process.call(agent_subject, 5000, GetAll)
  |> list.each(fn(expense) { io.println(string.inspect(expense)) })

  let today = expense_date |> date.get_month_year

  io.println("monthly detail: ")

  process.call(agent_subject, 5000, MonthlyDetail(today.month, today.year, _))
  |> list.each(fn(expense) { io.println(string.inspect(expense)) })

  io.println("monthly summary: ")

  let expense.Summary(total, categories_summary) =
    process.call(agent_subject, 5000, MonthlySummary(today.month, today.year, _))

  io.println("total: " <> float.to_string(total))
  categories_summary
  |> list.each(fn(expense) { io.println(string.inspect(expense)) })
}
