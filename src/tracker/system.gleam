import config
import gleam/io
import gleam/otp/static_supervisor.{type Supervisor, OneForOne}
import gleam/otp/supervision.{type ChildSpecification}
import tracker/registry

pub fn start_supervision_tree(
  config: config.Config,
) -> ChildSpecification(Supervisor) {
  io.println("Starting tracker supervision tree")

  static_supervisor.new(OneForOne)
  |> static_supervisor.add(registry.supervised(config.registry_name))
  |> static_supervisor.supervised
}
