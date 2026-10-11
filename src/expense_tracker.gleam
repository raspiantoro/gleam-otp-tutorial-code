import config.{type Config, Config}
import envoy
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/otp/actor
import gleam/otp/static_supervisor.{type Supervisor}
import gleam/result
import tracker/supervisor as tracker_supervisor
import web

fn start_supervision_tree(config: Config) -> actor.StartResult(Supervisor) {
  io.println("Starting supervision tree")

  static_supervisor.new(static_supervisor.OneForOne)
  |> static_supervisor.add(tracker_supervisor.supervised(config))
  |> static_supervisor.add(web.supervised(config))
  |> static_supervisor.start
}

pub fn main() -> Nil {
  let assert Ok(web_port) =
    envoy.get("WEB_PORT")
    |> result.unwrap("8080")
    |> int.parse
    as "WEB_PORT must be a valid integer"

  let config =
    Config(
      web_port:,
      registry_name: process.new_name("registry_actor"),
      agent_factory_name: process.new_name("agent_factory"),
    )

  let assert Ok(_) = start_supervision_tree(config)
    as "failed to start supervision tree"

  process.sleep_forever()
}
