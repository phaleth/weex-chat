defmodule WeexChat.Repo do
  use Ecto.Repo,
    otp_app: :weex_chat,
    adapter: Ecto.Adapters.Postgres
end
