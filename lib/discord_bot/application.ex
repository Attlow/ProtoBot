defmodule DiscordBot.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: DiscordBot.Worker.start_link(arg)
      # {DiscordBot.Worker, arg}
    ]

    opts = [strategy: :one_for_one, name: DiscordBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
