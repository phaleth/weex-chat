defmodule WeexChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WeexChatWeb.Telemetry,
      # Start the Ecto repository
      WeexChat.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: WeexChat.PubSub},
      # Start Finch
      {Finch, name: WeexChat.Finch},
      # Start the Endpoint (http/https)
      WeexChatWeb.Endpoint,
      # Start a worker by calling: WeexChat.Worker.start_link(arg)
      # {WeexChat.Worker, arg},
      # Start Phoenix Presence
      WeexChatWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WeexChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WeexChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
