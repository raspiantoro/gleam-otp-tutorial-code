import constants
import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/otp/actor
import gleam/otp/factory_supervisor.{type Message as FactoryMessage}
import gleam/otp/static_supervisor.{type Supervisor}
import gleam/otp/supervision
import gleam/result
import tracker/agent.{type AgentSubject, type Message as AgentMessage}

type FactoryName =
  process.Name(FactoryMessage(String, Subject(AgentMessage)))

pub opaque type Message {
  GetAgent(String, FactoryName, Subject(Result(AgentSubject, actor.StartError)))
  Down
}

pub type State =
  dict.Dict(String, AgentSubject)

pub fn handle_message(
  state: State,
  message: Message,
) -> actor.Next(State, Message) {
  case message {
    GetAgent(name, factory_name, reply_to) ->
      dict.get(state, name)
      |> result.map(fn(agent) {
        actor.send(reply_to, Ok(agent))
        actor.continue(state)
      })
      |> result.lazy_unwrap(fn() {
        handle_start_agent(name, state, factory_name, reply_to)
      })

    Down -> {
      io.println("Terminating registry")
      actor.stop()
    }
  }
}

pub fn start(
  name: process.Name(Message),
) -> fn() -> Result(actor.Started(Subject(Message)), actor.StartError) {
  fn() {
    io.println("Starting registry")

    actor.new(dict.new())
    |> actor.on_message(handle_message)
    |> actor.named(name)
    |> actor.start
  }
}

pub fn supervised(
  process_name name: process.Name(Message),
  agent_factory_name agent_name: FactoryName,
) -> supervision.ChildSpecification(Supervisor) {
  let agent_factory =
    factory_supervisor.worker_child(agent.start)
    |> factory_supervisor.named(agent_name)
    |> factory_supervisor.restart_strategy(supervision.Temporary)
    |> factory_supervisor.supervised

  static_supervisor.new(static_supervisor.OneForAll)
  |> static_supervisor.add(agent_factory)
  |> static_supervisor.add(supervision.worker(start(name)))
  |> static_supervisor.supervised
}

pub fn get_agent(
  subject: Subject(Message),
  factory_name: FactoryName,
  name: String,
) -> Result(AgentSubject, actor.StartError) {
  actor.call(subject, constants.timeout, GetAgent(name, factory_name, _))
}

pub fn down(subject: Subject(Message)) {
  actor.send(subject, Down)
}

fn handle_start_agent(
  name: String,
  state: State,
  factory_name: FactoryName,
  reply_to: Subject(Result(AgentSubject, actor.StartError)),
) -> actor.Next(State, Message) {
  factory_supervisor.get_by_name(factory_name)
  |> factory_supervisor.start_child(name)
  |> result.map(fn(agent) {
    actor.send(reply_to, Ok(agent.data))
    actor.continue(dict.insert(state, name, agent.data))
  })
  |> result.map_error(fn(error) { actor.send(reply_to, Error(error)) })
  |> result.unwrap(actor.continue(state))
}
