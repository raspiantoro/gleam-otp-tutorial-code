import constants
import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/otp/actor
import gleam/time/calendar
import tracker/catalog.{type Catalog}
import tracker/expense.{type CreateExpense, type Expense, type Summary}

import gleam/otp/factory_supervisor.{type Message as FactoryMessage}

pub type AgentFactoryName =
  process.Name(FactoryMessage(String, AgentSubject))

pub type AgentSubject =
  Subject(Message)

pub opaque type Message {
  Add(CreateExpense, Subject(Expense))
  GetAll(Subject(List(Expense)))
  MonthlyDetail(
    month: calendar.Month,
    year: Int,
    reply_to: Subject(List(Expense)),
  )
  MonthlySummary(month: calendar.Month, year: Int, reply_to: Subject(Summary))
}

fn handle_message(
  state: Catalog,
  message: Message,
) -> actor.Next(Catalog, Message) {
  case message {
    Add(create_expense, reply_to) -> {
      let #(new_expense, new_state) = catalog.add_expense(state, create_expense)
      actor.send(reply_to, new_expense)
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

pub fn start(
  name: String,
) -> Result(actor.Started(Subject(Message)), actor.StartError) {
  io.println("Starting agent: " <> name)

  let state = catalog.new()

  actor.new(state)
  |> actor.on_message(handle_message)
  |> actor.start
}

pub fn supervised(agent_factory_name: AgentFactoryName) {
  factory_supervisor.worker_child(start)
  |> factory_supervisor.named(agent_factory_name)
  |> factory_supervisor.supervised
}

pub fn add_expense(
  agent: Subject(Message),
  create_expense: CreateExpense,
) -> Expense {
  actor.call(agent, constants.timeout, Add(create_expense, _))
}

pub fn get_all(agent: Subject(Message)) -> List(Expense) {
  actor.call(agent, constants.timeout, GetAll)
}

pub fn monthly_detail(
  agent: Subject(Message),
  month month: calendar.Month,
  year year: Int,
) -> List(Expense) {
  actor.call(agent, constants.timeout, MonthlyDetail(month, year, _))
}

pub fn monthly_summary(
  agent: Subject(Message),
  month month: calendar.Month,
  year year: Int,
) -> Summary {
  actor.call(agent, constants.timeout, MonthlySummary(month, year, _))
}
