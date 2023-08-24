defmodule WeexChat.Chat.Message do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :from, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :from])
    |> validate_required([:content, :from])
  end
end
