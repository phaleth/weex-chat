defmodule WeexChat.Repo.Migrations.UpdateMessagesAddUserIdAndFrom do
  use Ecto.Migration

  def up do
    alter table(:messages) do
      add(:from, :string, default: "Guest")
      add(:user_id, :id, null: true)
    end
  end

  def down do
    alter table(:messages) do
      remove(:from)
      remove(:user_id)
    end
  end
end
