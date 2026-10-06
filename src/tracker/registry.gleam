import constants
import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/otp/actor
import gleam/result
import tracker/agent

pub opaque type Message {
  GetAgent(String, Subject(Result(Subject(agent.Message), actor.StartError)))
}

pub fn handle_message(
  state: dict.Dict(String, Subject(agent.Message)),
  message: Message,
) -> actor.Next(dict.Dict(String, Subject(agent.Message)), Message) {
  case message {
    GetAgent(name, reply_to) ->
      dict.get(state, name)
      |> result.map(fn(agent) {
        actor.send(reply_to, Ok(agent))
        actor.continue(state)
      })
      |> result.lazy_unwrap(fn() { handle_start_agent(name, state, reply_to) })
  }
}

pub fn start() -> Result(Subject(Message), actor.StartError) {
  io.println("Starting registry")

  actor.new(dict.new())
  |> actor.on_message(handle_message)
  |> actor.start
  |> result.map(fn(started_actor) { started_actor.data })
}

pub fn get_agent(
  subject: Subject(Message),
  name: String,
) -> Result(Subject(agent.Message), actor.StartError) {
  actor.call(subject, constants.timeout, GetAgent(name, _))
}

fn handle_start_agent(
  name: String,
  state: dict.Dict(String, Subject(agent.Message)),
  reply_to: Subject(Result(Subject(agent.Message), actor.StartError)),
) -> actor.Next(dict.Dict(String, Subject(agent.Message)), Message) {
  let state =
    agent.start()
    |> result.map(fn(agent) {
      actor.send(reply_to, Ok(agent))
      dict.insert(state, name, agent)
    })
    |> result.map_error(fn(error) { actor.send(reply_to, Error(error)) })
    |> result.unwrap(state)

  actor.continue(state)
}
