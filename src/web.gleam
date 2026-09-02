import config.{type Config}
import gleam/io
import mist
import tracker/router
import wisp.{type Request, type Response}
import wisp/wisp_mist

pub fn start(cfg: Config) {
  io.println("Starting web server")

  handler(cfg, _)
  |> wisp_mist.handler("")
  |> mist.new
  |> mist.port(cfg.web_port)
  |> mist.start
}

pub fn handler(cfg: Config, req: Request) -> Response {
  let path = wisp.path_segments(req)
  use <- wisp.rescue_crashes
  case path {
    ["tracker", ..rest] -> router.handle_request(cfg, req, rest)
    _ -> wisp.not_found()
  }
}
