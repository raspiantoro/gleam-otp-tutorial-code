import gleam/dynamic/decode.{type Decoder}
import gleam/json
import gleam/option
import tempo.{type Date}
import tempo/date
import tracker/expense.{
  type Category, type CategorySummary, type CreateExpense, type Expense,
  type Summary, CreateExpense,
}

pub fn expense_to_json(entry: Expense) -> json.Json {
  json.object([
    #("id", json.int(entry.id)),
    #("amount", json.float(entry.amount)),
    #("category", expense_category_to_json(entry.category)),
    #("date", json.string(date.to_string(entry.date))),
    #("note", json.nullable(entry.note, of: fn(note) { json.string(note) })),
  ])
}

fn expense_category_to_json(category: Category) -> json.Json {
  case category {
    expense.Other(value) -> json.object([#("other", json.string(value))])
    _ -> json.string(expense.category_to_string(category))
  }
}

pub fn create_expense_decoder() -> Decoder(CreateExpense) {
  use amount <- decode.field("amount", decode.float)
  use category <- decode.field("category", decode.string)
  use date <- decode.field("date", date_decoder())
  use note <- decode.optional_field(
    "note",
    option.None,
    decode.optional(decode.string),
  )

  let category = expense.category_from_string(category)

  decode.success(CreateExpense(amount:, category:, date:, note:))
}

pub fn expense_summary_to_json(summary: Summary) -> json.Json {
  json.object([
    #("total", json.float(summary.total)),
    #(
      "categories",
      json.array(summary.category_summaries, expense_category_summary_to_json),
    ),
  ])
}

fn expense_category_summary_to_json(
  category_summary: CategorySummary,
) -> json.Json {
  json.object([
    #(
      "category",
      json.string(expense.category_to_string(category_summary.category)),
    ),
    #("total", json.float(category_summary.total)),
  ])
}

fn date_decoder() -> Decoder(Date) {
  use date_string <- decode.then(decode.string)
  case date.from_string(date_string) {
    Ok(date) -> decode.success(date)
    Error(_) -> decode.failure(date.literal("1970-01-01"), "Date")
  }
}
