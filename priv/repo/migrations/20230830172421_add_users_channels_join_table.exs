defmodule WeexChat.Repo.Migrations.AddUsersChannelsJoinTable do
  use Ecto.Migration

  def change do
    create table(:users_channels, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :channel_id, references(:channels, on_delete: :delete_all)
    end

    create(unique_index(:users_channels, [:user_id, :channel_id]))
  end
end
