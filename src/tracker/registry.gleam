import constants
import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/otp/actor
import gleam/result
import tracker/agent.{type AgentSubject}

pub opaque type Message {
  GetAgent(String, Subject(Result(AgentSubject, actor.StartError)))
}

type State =
  dict.Dict(String, AgentSubject)

pub fn start() -> Result(Subject(Message), actor.StartError) {
  io.println("Starting registry")

  actor.new(dict.new())
  |> actor.on_message(handle_message)
  |> actor.start
  |> result.map(fn(started_actor) { started_actor.data })
}

pub fn get_agent(
  subject: Subject(Message),
  tracker_name: String,
) -> Result(AgentSubject, actor.StartError) {
  actor.call(subject, constants.timeout, GetAgent(tracker_name, _))
}

fn handle_message(
  state: State,
  message: Message,
) -> actor.Next(State, Message) {
  case message {
    GetAgent(tracker_name, reply_to) ->
      dict.get(state, tracker_name)
      |> result.map(fn(agent) {
        actor.send(reply_to, Ok(agent))
        actor.continue(state)
      })
      |> result.lazy_unwrap(fn() {
        handle_start_agent(tracker_name, state, reply_to)
      })
  }
}

fn handle_start_agent(
  tracker_name: String,
  state: State,
  reply_to: Subject(Result(AgentSubject, actor.StartError)),
) -> actor.Next(State, Message) {
  let state =
    agent.start()
    |> result.map(fn(agent) {
      actor.send(reply_to, Ok(agent))
      dict.insert(state, tracker_name, agent)
    })
    |> result.map_error(fn(error) { actor.send(reply_to, Error(error)) })
    |> result.unwrap(state)

  actor.continue(state)
}
