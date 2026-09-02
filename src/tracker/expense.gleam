import gleam/option.{type Option}
import gleam/string
import tempo

pub type Category {
  Food
  Transport
  Entertainment
  Health
  Other(String)
}

pub fn category_from_string(category: String) -> Category {
  let lower_category = string.lowercase(category)

  case lower_category {
    "food" -> Food
    "transport" -> Transport
    "entertainment" -> Entertainment
    "health" -> Health
    _ -> Other(category)
  }
}

pub fn category_to_string(category: Category) -> String {
  case category {
    Food -> "Food"
    Transport -> "Transport"
    Entertainment -> "Entertainment"
    Health -> "Health"
    Other(_) -> "Other"
  }
}

pub type CategorySummary {
  CategorySummary(category: Category, total: Float)
}

pub type Summary {
  Summary(total: Float, category_summaries: List(CategorySummary))
}

pub type CreateExpense {
  CreateExpense(
    amount: Float,
    category: Category,
    date: tempo.Date,
    note: Option(String),
  )
}

pub type Expense {
  Expense(
    id: Int,
    amount: Float,
    category: Category,
    date: tempo.Date,
    note: Option(String),
  )
}

pub fn new(id: Int, create_expense: CreateExpense) -> Expense {
  Expense(
    id:,
    amount: create_expense.amount,
    category: create_expense.category,
    date: create_expense.date,
    note: create_expense.note,
  )
}
