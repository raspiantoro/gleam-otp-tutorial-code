import gleam/erlang/process.{type Subject}
import tracker/registry.{type Message}

pub type Config {
  Config(web_port: Int, registry: Subject(Message))
}
