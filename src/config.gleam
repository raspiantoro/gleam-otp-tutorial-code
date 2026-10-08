import gleam/erlang/process
import tracker/registry.{type Message}

pub type Config {
  Config(web_port: Int, registry_name: process.Name(Message))
}
