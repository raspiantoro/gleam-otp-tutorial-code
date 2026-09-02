import config.{Config}
import envoy
import gleam/erlang/process
import gleam/int
import gleam/result
import tracker/agent
import web

pub fn main() -> Nil {
  let assert Ok(web_port) =
    envoy.get("WEB_PORT")
    |> result.unwrap("8080")
    |> int.parse
    as "WEB_PORT must be a valid integer"

  let assert Ok(catalog_agent) = agent.start() as "failed to start the agent"

  let config = Config(web_port:, agent: catalog_agent)
  let assert Ok(_) = web.start(config) as "failed to start the web server"

  process.sleep_forever()
}
