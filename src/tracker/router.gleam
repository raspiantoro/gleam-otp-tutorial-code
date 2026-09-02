import config.{type Config}
import gleam/dynamic/decode
import gleam/http.{Get, Post}
import gleam/json
import gleam/result
import tempo/date
import tempo/instant
import tracker/agent
import tracker/codec
import wisp.{type Request, type Response}

pub fn handle_request(
  config cfg: Config,
  request req: Request,
  path_segments path: List(String),
) -> Response {
  case path, req.method {
    [], Get -> get_all(cfg)
    [], Post -> add_expense(cfg, req)
    ["monthly"], Get -> get_monthly(cfg)
    ["summary"], Get -> get_summary(cfg)
    _, _ -> wisp.not_found()
  }
}

fn get_all(cfg: Config) -> Response {
  agent.get_all(cfg.agent)
  |> json.array(codec.expense_to_json)
  |> json.to_string
  |> wisp.json_response(200)
}

fn add_expense(cfg: Config, req: Request) -> Response {
  use body <- wisp.require_json(req)
  let created_expense = {
    use create_expense <- result.try(decode.run(
      body,
      codec.create_expense_decoder(),
    ))

    Ok(agent.add_expense(cfg.agent, create_expense))
  }

  case created_expense {
    Ok(created_expense) ->
      codec.expense_to_json(created_expense)
      |> json.to_string
      |> wisp.json_response(200)
    Error(_) -> wisp.bad_request("Invalid request body")
  }
}

fn get_monthly(cfg: Config) -> Response {
  let today =
    instant.now()
    |> instant.as_local_date
    |> date.get_month_year

  agent.monthly_detail(cfg.agent, today.month, today.year)
  |> json.array(codec.expense_to_json)
  |> json.to_string
  |> wisp.json_response(200)
}

fn get_summary(cfg: Config) -> Response {
  let today =
    instant.now()
    |> instant.as_local_date
    |> date.get_month_year

  agent.monthly_summary(cfg.agent, today.month, today.year)
  |> codec.expense_summary_to_json
  |> json.to_string
  |> wisp.json_response(200)
}
