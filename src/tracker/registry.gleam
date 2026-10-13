import constants
import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/otp/actor
import gleam/otp/factory_supervisor
import gleam/otp/supervision
import gleam/result
import tracker/agent.{type AgentFactoryName, type AgentSubject}

pub opaque type Message {
  GetAgent(String, Subject(Result(AgentSubject, actor.StartError)))
  Down
}

type State {
  State(
    agent_factory_name: AgentFactoryName,
    agents: dict.Dict(String, AgentSubject),
  )
}

pub fn start(
  name: process.Name(Message),
  agent_factory_name: AgentFactoryName,
) -> fn() -> Result(actor.Started(Subject(Message)), actor.StartError) {
  fn() {
    io.println("Starting registry")

    actor.new(State(agent_factory_name:, agents: dict.new()))
    |> actor.on_message(handle_message)
    |> actor.named(name)
    |> actor.start
  }
}

pub fn supervised(
  name: process.Name(Message),
  agent_factory_name: AgentFactoryName,
) -> supervision.ChildSpecification(Subject(Message)) {
  supervision.worker(start(name, agent_factory_name))
}

pub fn get_agent(
  subject: Subject(Message),
  tracker_name: String,
) -> Result(AgentSubject, actor.StartError) {
  actor.call(subject, constants.timeout, GetAgent(tracker_name, _))
}

pub fn down(subject: Subject(Message)) {
  actor.send(subject, Down)
}

fn handle_message(
  state: State,
  message: Message,
) -> actor.Next(State, Message) {
  case message {
    GetAgent(tracker_name, reply_to) ->
      dict.get(state.agents, tracker_name)
      |> result.map(fn(agent) {
        actor.send(reply_to, Ok(agent))
        actor.continue(state)
      })
      |> result.lazy_unwrap(fn() {
        handle_start_agent(tracker_name, state, reply_to)
      })

    Down -> {
      io.println("Terminating registry")
      actor.stop()
    }
  }
}

fn handle_start_agent(
  tracker_name: String,
  state: State,
  reply_to: Subject(Result(AgentSubject, actor.StartError)),
) -> actor.Next(State, Message) {
  factory_supervisor.get_by_name(state.agent_factory_name)
  |> factory_supervisor.start_child(tracker_name)
  |> result.map(fn(agent) {
    actor.send(reply_to, Ok(agent.data))
    actor.continue(
      State(
        ..state,
        agents: dict.insert(state.agents, tracker_name, agent.data),
      ),
    )
  })
  |> result.map_error(fn(error) { actor.send(reply_to, Error(error)) })
  |> result.unwrap(actor.continue(state))
}
