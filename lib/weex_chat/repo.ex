defmodule WeexChat.Repo do
  use Ecto.Repo,
    otp_app: :weex_chat,
    adapter:
      if(Mix.env() in [:dev, :prod],
        do: Ecto.Adapters.SQLite3,
        else: Ecto.Adapters.Postgres
      )
end
