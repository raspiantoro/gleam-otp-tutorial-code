import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/string
import gleam/time/calendar
import tracker/catalog
import tracker/expense.{type CreateExpense, type Expense, type Summary}

pub type Message {
  Add(CreateExpense)
  GetAll(Subject(List(Expense)))
  MonthlyDetail(
    month: calendar.Month,
    year: Int,
    reply_to: Subject(List(Expense)),
  )
  MonthlySummary(month: calendar.Month, year: Int, reply_to: Subject(Summary))
}

fn handle_message(state: catalog.Catalog, subject: Subject(Message)) {
  let new_state = case process.receive(subject, 5000) {
    Ok(message) ->
      case message {
        Add(create_expense) -> {
          io.println("receive Add message: " <> string.inspect(create_expense))
          catalog.add_expense(state, create_expense)
        }
        GetAll(reply_to) -> {
          io.println("receive GetAll message")
          process.send(reply_to, state |> catalog.all |> dict.values)
          state
        }
        MonthlyDetail(month:, year:, reply_to:) -> {
          process.send(
            reply_to,
            state |> catalog.monthly_detail(month:, year:) |> dict.values,
          )
          state
        }
        MonthlySummary(month:, year:, reply_to:) -> {
          process.send(
            reply_to,
            state |> catalog.monthly_summary(month:, year:),
          )
          state
        }
      }
    Error(_) -> state
  }

  handle_message(new_state, subject)
}

pub fn run() -> Subject(Message) {
  let reply_subject = process.new_subject()

  process.spawn(fn() {
    let new_subject = process.new_subject()
    process.send(reply_subject, new_subject)
    handle_message(catalog.new(), new_subject)
  })

  let assert Ok(subject) = process.receive(reply_subject, 5000)
  subject
}
