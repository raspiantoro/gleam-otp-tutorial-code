import gleam/dict
import gleam/float
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import tempo/date
import tracker/catalog
import tracker/expense

pub fn main() -> Nil {
  let expense_catalog = catalog.new()

  let assert Ok(expense_date) = date.from_string("2026-7-21")

  let create_expense =
    expense.CreateExpense(
      4.5,
      expense.category_from_string("Food"),
      expense_date,
      option.Some("Morning coffee"),
    )

  let expense_catalog = catalog.add_expense(expense_catalog, create_expense)

  let create_expense =
    expense.CreateExpense(
      49.0,
      expense.category_from_string("Education"),
      expense_date,
      option.Some("Online course subscription"),
    )

  let expense_catalog = catalog.add_expense(expense_catalog, create_expense)

  let create_expense =
    expense.CreateExpense(
      20.0,
      expense.category_from_string("Gift"),
      date.literal("2026-7-22"),
      option.Some("Charity donation"),
    )

  let expense_catalog = catalog.add_expense(expense_catalog, create_expense)

  let today = expense_date |> date.get_month_year

  io.println("monthly detail: ")

  expense_catalog
  |> catalog.monthly_detail(today.month, today.year)
  |> dict.values
  |> list.each(fn(expense) { io.println(string.inspect(expense)) })

  io.println("monthly summary: ")

  let expense.Summary(total, categories_summary) =
    expense_catalog
    |> catalog.monthly_summary(today.month, today.year)

  io.println("total: " <> float.to_string(total))
  categories_summary
  |> list.each(fn(expense) { io.println(string.inspect(expense)) })
}
