import constants
import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/otp/actor
import gleam/otp/supervision
import gleam/result
import tracker/agent.{type AgentSubject}

pub opaque type Message {
  GetAgent(String, Subject(Result(AgentSubject, actor.StartError)))
  Down
}

type State =
  dict.Dict(String, AgentSubject)

pub fn start() -> fn() ->
  Result(actor.Started(Subject(Message)), actor.StartError) {
  fn() {
    io.println("Starting registry")

    actor.new(dict.new())
    |> actor.on_message(handle_message)
    |> actor.start
  }
}

// pub fn start(
//   reply_to: Subject(Subject(Message)),
// ) -> fn() -> Result(actor.Started(Subject(Message)), actor.StartError) {
//   fn() {
//     io.println("Starting registry")

//     actor.new(dict.new())
//     |> actor.on_message(handle_message)
//     |> actor.start
//     |> result.map(fn(started_actor) {
//       process.send(reply_to, started_actor.data)
//       started_actor
//     })
//   }
// }

pub fn supervised() -> supervision.ChildSpecification(Subject(Message)) {
  supervision.ChildSpecification(
    start: start(),
    restart: supervision.Permanent,
    significant: False,
    child_type: supervision.Worker(constants.timeout),
  )
}

// pub fn supervised(
//   reply_to: Subject(Subject(Message)),
// ) -> supervision.ChildSpecification(Subject(Message)) {
//   supervision.ChildSpecification(
//     start: start(reply_to),
//     restart: supervision.Permanent,
//     significant: False,
//     child_type: supervision.Worker(constants.timeout),
//   )
// }

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
      dict.get(state, tracker_name)
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
