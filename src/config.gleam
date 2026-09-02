import gleam/erlang/process.{type Subject}
import tracker/agent.{type Message}

pub type Config {
  Config(web_port: Int, agent: Subject(Message))
}
