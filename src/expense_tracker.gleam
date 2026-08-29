import config.{Config}
import envoy
import gleam/erlang/process
import gleam/int
import gleam/result
import tracker/agent
import web

pub fn main() -> Nil {
  let assert Ok(catalog_agent) = agent.start()

  let assert Ok(web_port) =
    envoy.get("WEB_PORT")
    |> result.unwrap("8080")
    |> int.parse

  let config = Config(web_port:, agent: catalog_agent)
  let _ = web.start(config)

  process.sleep_forever()
}
