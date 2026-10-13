import config.{type Config}
import gleam/io
import gleam/otp/static_supervisor.{type Supervisor, OneForOne}
import gleam/otp/supervision.{type ChildSpecification}
import tracker/registry

import tracker/agent

pub fn supervised(config: Config) -> ChildSpecification(Supervisor) {
  io.println("Starting tracker supervision tree")

  let agent_hub_supervisor =
    static_supervisor.new(static_supervisor.OneForAll)
    |> static_supervisor.add(agent.factory_spec(config.agent_factory_name))
    |> static_supervisor.add(
      supervision.worker(registry.start(
        config.registry_name,
        config.agent_factory_name,
      )),
    )
    |> static_supervisor.supervised

  static_supervisor.new(OneForOne)
  |> static_supervisor.add(agent_hub_supervisor)
  |> static_supervisor.supervised
}
