defmodule WeexChat.Rooms.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "channels" do
    field :name, :string
    field :creator_id, :id
    field :member_id, :id
    field :user_is_guest, :boolean, default: false
    many_to_many :users, WeexChat.Accounts.User, join_through: "users_channels"

    timestamps()
  end

  @doc false
  def changeset(channel, attrs, users \\ []) do
    channel
    |> cast(attrs, [:name, :user_is_guest])
    |> validate_required([:name, :user_is_guest])
    |> put_assoc(:users, users)
  end
end
