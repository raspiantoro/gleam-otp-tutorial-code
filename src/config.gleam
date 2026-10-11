import gleam/erlang/process.{type Name}
import tracker/registry.{type Message}

pub type Config {
  Config(web_port: Int, registry_name: Name(Message))
}
