import config.{type Config}
import gleam/erlang/process
import gleam/io
import gleam/otp/static_supervisor.{type Supervisor}
import gleam/otp/supervision.{type ChildSpecification}
import mist
import tracker/registry
import tracker/router
import wisp.{type Request, type Response}
import wisp/wisp_mist

pub fn supervised(cfg: Config) -> ChildSpecification(Supervisor) {
  io.println("Starting web server")

  handler(cfg, _)
  |> wisp_mist.handler("")
  |> mist.new
  |> mist.port(cfg.web_port)
  |> mist.supervised
}

pub fn handler(cfg: Config, req: Request) -> Response {
  let path = wisp.path_segments(req)
  use <- wisp.rescue_crashes
  case path {
    ["tracker", ..rest] -> router.handle_request(cfg, req, rest)
    ["registry", "down"] -> {
      registry.down(cfg.registry_name |> process.named_subject)
      wisp.response(200)
    }
    _ -> wisp.not_found()
  }
}
