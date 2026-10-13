import gleam/erlang/process
import tracker/agent.{type AgentFactoryName}
import tracker/registry.{type Message as RegistryMessage}

pub type Config {
  Config(
    web_port: Int,
    registry_name: process.Name(RegistryMessage),
    agent_factory_name: AgentFactoryName,
  )
}
