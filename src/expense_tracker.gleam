import config.{Config}
import envoy
import gleam/erlang/process
import gleam/int
import gleam/result
import tracker/registry
import web

pub fn main() -> Nil {
  let assert Ok(web_port) =
    envoy.get("WEB_PORT")
    |> result.unwrap("8080")
    |> int.parse
    as "WEB_PORT must be a valid integer"

  let assert Ok(agent_registry) = registry.start()
    as "failed to start the registry"

  let config = Config(web_port:, registry: agent_registry)

  let assert Ok(_) = web.start(config) as "cannot start web server"

  process.sleep_forever()
}
