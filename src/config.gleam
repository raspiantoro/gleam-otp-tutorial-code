import gleam/erlang/process
import gleam/otp/factory_supervisor.{type Message as FactoryMessage}
import tracker/agent.{type Message as AgentMessage}
import tracker/registry.{type Message as RegistryMessage}

pub type Config {
  Config(
    web_port: Int,
    registry_name: process.Name(RegistryMessage),
    agent_factory_name: process.Name(
      FactoryMessage(String, process.Subject(AgentMessage)),
    ),
  )
}
