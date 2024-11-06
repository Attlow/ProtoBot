defmodule ProtoBot.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ProtoBot
    ]

    opts = [strategy: :one_for_one, name: ProtoBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
