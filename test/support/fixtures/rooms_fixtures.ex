defmodule WeexChat.RoomsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WeexChat.Rooms` context.
  """

  @doc """
  Generate a channel.
  """
  def channel_fixture(attrs \\ %{}) do
    {:ok, channel} =
      attrs
      |> Enum.into(%{
        name: "channel-name",
        user_is_guest: true
      })
      |> WeexChat.Rooms.create_channel()

    channel
  end
end
