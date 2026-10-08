import gleam/io
import gleam/otp/static_supervisor.{type Supervisor, OneForOne}
import gleam/otp/supervision.{type ChildSpecification}

import gleam/erlang/process.{type Subject}
import tracker/registry.{type Message}

pub fn start_supervision_tree() -> ChildSpecification(Supervisor) {
  io.println("Starting tracker supervision tree")

  static_supervisor.new(OneForOne)
  |> static_supervisor.add(registry.supervised())
  |> static_supervisor.supervised
}
// pub fn start_supervision_tree(
//   reply_to: Subject(Subject(Message)),
// ) -> ChildSpecification(Supervisor) {
//   io.println("Starting tracker supervision tree")

//   static_supervisor.new(OneForOne)
//   |> static_supervisor.add(registry.supervised(reply_to))
//   |> static_supervisor.supervised
// }
