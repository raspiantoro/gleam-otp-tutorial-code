import gleam/erlang/process.{type Subject}
import tracker/agent.{type Message}

pub type Config {
  Config(web_port: Int, agent: Subject(Message))
}

pub fn default() -> Config {
  Config(web_port: 8080, agent: process.new_subject())
}
