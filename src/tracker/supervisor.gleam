import config.{type Config}
import gleam/io
import gleam/otp/static_supervisor.{type Supervisor, OneForAll}
import gleam/otp/supervision.{type ChildSpecification}
import tracker/registry

import tracker/agent

pub fn supervised(config: Config) -> ChildSpecification(Supervisor) {
  io.println("Starting tracker supervision tree")

  static_supervisor.new(OneForAll)
  |> static_supervisor.add(agent.supervised(config.agent_factory_name))
  |> static_supervisor.add(
    supervision.worker(registry.start(
      config.registry_name,
      config.agent_factory_name,
    )),
  )
  |> static_supervisor.supervised
}
