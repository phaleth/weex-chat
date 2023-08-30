defmodule WeexChat.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :creator_id, :id
      add :member_id, :id, null: true
      add :user_is_guest, :boolean, default: false, null: false

      timestamps()
    end
  end
end
