import config.{type Config}
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/http
import gleam/json
import gleam/result
import tempo/date
import tempo/instant
import tracker/agent
import tracker/codec
import tracker/registry
import wisp.{type Request, type Response}

pub fn handle_request(
  config cfg: Config,
  request req: Request,
  path_segments path: List(String),
) -> Response {
  case path, req.method {
    ["monthly"], _ | ["summary"], _ -> wisp.not_found()
    [tracker_name], http.Get -> get_all(cfg, tracker_name)
    [tracker_name], http.Post -> add_expense(cfg, req, tracker_name)
    [tracker_name, "monthly"], http.Get -> get_monthly(cfg, tracker_name)
    [tracker_name, "summary"], http.Get -> get_summary(cfg, tracker_name)
    _, _ -> wisp.not_found()
  }
}

fn get_all(cfg: Config, tracker_name: String) -> Response {
  let subject = process.named_subject(cfg.registry_name)

  case registry.get_agent(subject, tracker_name) {
    Error(_) -> wisp.internal_server_error()
    Ok(agent) ->
      agent.get_all(agent)
      |> json.array(codec.expense_to_json)
      |> json.to_string
      |> wisp.json_response(200)
  }
}

fn add_expense(cfg: Config, req: Request, tracker_name: String) -> Response {
  use body <- wisp.require_json(req)
  let created_expense = {
    let subject = process.named_subject(cfg.registry_name)

    use agent <- result.try(
      registry.get_agent(subject, tracker_name)
      |> result.replace_error(wisp.internal_server_error()),
    )

    use create_expense <- result.try(
      decode.run(body, codec.create_expense_decoder())
      |> result.replace_error(wisp.bad_request("Invalid request body")),
    )

    Ok(agent.add_expense(agent, create_expense))
  }

  case created_expense {
    Ok(created_expense) ->
      codec.expense_to_json(created_expense)
      |> json.to_string
      |> wisp.json_response(200)
    Error(error_response) -> error_response
  }
}

fn get_monthly(cfg: Config, tracker_name: String) -> Response {
  let today =
    instant.now()
    |> instant.as_local_date
    |> date.get_month_year

  let subject = process.named_subject(cfg.registry_name)

  case registry.get_agent(subject, tracker_name) {
    Error(_) -> wisp.internal_server_error()
    Ok(agent) ->
      agent.monthly_detail(agent, today.month, today.year)
      |> json.array(codec.expense_to_json)
      |> json.to_string
      |> wisp.json_response(200)
  }
}

fn get_summary(cfg: Config, tracker_name: String) -> Response {
  let today =
    instant.now()
    |> instant.as_local_date
    |> date.get_month_year

  let subject = process.named_subject(cfg.registry_name)

  case registry.get_agent(subject, tracker_name) {
    Error(_) -> wisp.internal_server_error()
    Ok(agent) ->
      agent.monthly_summary(agent, today.month, today.year)
      |> codec.expense_summary_to_json
      |> json.to_string
      |> wisp.json_response(200)
  }
}
