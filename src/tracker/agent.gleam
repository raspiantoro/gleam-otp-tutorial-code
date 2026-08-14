import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import gleam/result
import gleam/time/calendar
import tracker/catalog.{type Catalog}
import tracker/expense.{type CreateExpense, type Expense, type Summary}

const timeout = 5000

pub opaque type Message {
  Add(CreateExpense)
  GetAll(Subject(List(Expense)))
  MonthlyDetail(
    month: calendar.Month,
    year: Int,
    reply_to: Subject(List(Expense)),
  )
  MonthlySummary(month: calendar.Month, year: Int, reply_to: Subject(Summary))
}

pub fn handle_message(
  state: Catalog,
  message: Message,
) -> actor.Next(Catalog, Message) {
  case message {
    Add(create_expense) -> {
      let new_state = catalog.add_expense(state, create_expense)
      actor.continue(new_state)
    }

    GetAll(reply_to) -> {
      process.send(reply_to, catalog.all(state) |> dict.values)
      actor.continue(state)
    }

    MonthlyDetail(month:, year:, reply_to:) -> {
      process.send(
        reply_to,
        catalog.monthly_detail(state, month:, year:) |> dict.values,
      )
      actor.continue(state)
    }

    MonthlySummary(month:, year:, reply_to:) -> {
      process.send(reply_to, catalog.monthly_summary(state, month:, year:))
      actor.continue(state)
    }
  }
}

pub fn start() -> Result(Subject(Message), actor.StartError) {
  let state = catalog.new()

  actor.new(state)
  |> actor.on_message(handle_message)
  |> actor.start
  |> result.map(fn(started_actor) { started_actor.data })
}

pub fn add_expense(agent: Subject(Message), create_expense: CreateExpense) {
  actor.send(agent, Add(create_expense))
}

pub fn get_all(agent: Subject(Message)) -> List(Expense) {
  actor.call(agent, timeout, GetAll)
}

pub fn monthly_detail(
  agent: Subject(Message),
  month month: calendar.Month,
  year year: Int,
) -> List(Expense) {
  actor.call(agent, timeout, MonthlyDetail(month, year, _))
}

pub fn monthly_summary(
  agent: Subject(Message),
  month month: calendar.Month,
  year year: Int,
) -> Summary {
  actor.call(agent, timeout, MonthlySummary(month, year, _))
}
