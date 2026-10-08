import config.{Config}
import envoy
import gleam/erlang/process
import gleam/int
import gleam/otp/static_supervisor
import gleam/result
import tracker/system
import web

import constants

pub fn main() -> Nil {
  let assert Ok(web_port) =
    envoy.get("WEB_PORT")
    |> result.unwrap("8080")
    |> int.parse
    as "WEB_PORT must be a valid integer"

  // let reply_subject = process.new_subject()

  // let assert Ok(_) =
  //   static_supervisor.new(static_supervisor.OneForOne)
  //   |> static_supervisor.add(system.start_supervision_tree(reply_subject))
  //   |> static_supervisor.start
  //   as "failed to start supervisor"

  let assert Ok(_) =
    static_supervisor.new(static_supervisor.OneForOne)
    |> static_supervisor.add(system.start_supervision_tree())
    |> static_supervisor.start
    as "failed to start supervisor"

  // let assert Ok(agent_registry) =
  //   process.receive(reply_subject, constants.timeout)

  let config = Config(web_port:, registry: agent_registry)

  let assert Ok(_) = web.start(config) as "cannot start web server"

  process.sleep_forever()
}
