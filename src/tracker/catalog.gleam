import gleam/dict
import gleam/list
import gleam/time/calendar
import tempo
import tempo/date
import tracker/expense.{
  type CreateExpense, type Expense, type Summary, CategorySummary,
}

pub type Catalog {
  Catalog(next_id: Int, expenses: dict.Dict(Int, Expense))
}

pub fn new() -> Catalog {
  Catalog(1, dict.new())
}

pub fn add_expense(catalog: Catalog, expense: CreateExpense) -> Catalog {
  let new_expense = expense.new(catalog.next_id, expense)
  Catalog(
    next_id: catalog.next_id + 1,
    expenses: dict.insert(catalog.expenses, catalog.next_id, new_expense),
  )
}

pub fn all(catalog: Catalog) -> dict.Dict(Int, Expense) {
  catalog.expenses
}

pub fn monthly_detail(
  catalog: Catalog,
  month month: calendar.Month,
  year year: Int,
) -> dict.Dict(Int, Expense) {
  catalog.expenses
  |> dict.filter(fn(_, entry) {
    date.get_month_year(entry.date) == tempo.MonthYear(month:, year:)
  })
}

pub fn monthly_summary(
  catalog: Catalog,
  month month: calendar.Month,
  year year: Int,
) -> Summary {
  let monthly =
    monthly_detail(catalog, month, year)
    |> dict.values

  let total =
    monthly
    |> list.fold(0.0, fn(acc, entry) { acc +. entry.amount })

  let category_summaries =
    monthly
    |> list.map(fn(entry) {
      let category = case entry.category {
        expense.Other(_) -> expense.Other("Other")
        _ -> entry.category
      }

      expense.Expense(..entry, category:)
    })
    |> list.group(fn(entry) { entry.category })
    |> dict.map_values(fn(_, expenses) {
      list.fold(expenses, 0.0, fn(acc, entry) { acc +. entry.amount })
    })
    |> dict.to_list
    |> list.map(fn(pair) { CategorySummary(category: pair.0, total: pair.1) })

  expense.Summary(total:, category_summaries:)
}
