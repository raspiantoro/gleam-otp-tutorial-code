import config.{Config}
import gleam/erlang/process
import gleam/io
import tracker/agent
import web

pub fn main() -> Nil {
  io.println("Hello from expense_tracker!")

  let assert Ok(catalog_agent) = agent.start()
  let config = Config(..config.default(), agent: catalog_agent)
  let _ = web.start(config)

  process.sleep_forever()
}
