defmodule Bubble.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Redix, host: Application.get_env(:bubble, :redis_host), name: :redix},
      BubbleWeb.Endpoint,
    ]

    opts = [strategy: :one_for_one, name: Bubble.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    BubbleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
