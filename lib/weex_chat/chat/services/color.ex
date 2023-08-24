defmodule WeexChat.Chat.Services.Color do
  @moduledoc false
  alias WeexChat.Chat
  alias WeexChat.Generators.Color

  def list_messages() do
    Chat.list_messages()
    |> Enum.map(&Map.put(&1, :from_color, Color.get(&1.from)))
  end
end
