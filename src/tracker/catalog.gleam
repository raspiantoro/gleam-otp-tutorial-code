import gleam/dict
import gleam/list
import gleam/time/calendar
import tempo
import tempo/date
import tracker/expense.{
  type CreateExpense, type Expense, type Summary, CategorySummary,
}

pub opaque type Catalog {
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
    // monthly_detail returns a Dict(Int, Expense) — Int keys are the expense
    // ids, already filtered down to this month/year
    monthly_detail(catalog, month, year)
    // we only need the Expense values for the math below, so drop the ids
    // and turn it into a plain List(Expense)
    |> dict.values

  let total =
    monthly
    // list.fold walks the list one item at a time, carrying an accumulator
    // forward. starts at 0.0, and for each entry adds its amount to acc —
    // basically a running sum, same idea as reduce() if you know JS
    |> list.fold(0.0, fn(acc, entry) { acc +. entry.amount })

  let category_summaries =
    monthly
    // map over every expense so we can adjust its category before grouping
    |> list.map(fn(entry) {
      let category = case entry.category {
        // group all custom categories under one Other("Other") label so
        // they show up as a single "Other" row in the summary instead of
        // one row per custom string
        expense.Other(_) -> expense.Other("Other")
        _ -> entry.category
      }

      // creates a new Expense with the same fields as entry,
      // except using the updated category from above.
      expense.Expense(..entry, category:)
    })
    // bucket the expenses into a Dict(Category, List(Expense)) based on
    // the (now normalized) category field
    |> list.group(fn(entry) { entry.category })
    // turn each bucket's list of expenses into a single total
    |> dict.map_values(fn(_, expenses) {
      list.fold(expenses, 0.0, fn(acc, entry) { acc +. entry.amount })
    })
    // Dict(Category, Float) -> List(#(Category, Float)) so we can map it
    // into our own record type next
    |> dict.to_list
    // wrap each tuple into a proper CategorySummary
    |> list.map(fn(pair) { CategorySummary(category: pair.0, total: pair.1) })

  expense.Summary(total:, category_summaries:)
}
