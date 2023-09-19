defmodule WeexChat.RoomsTest do
  use WeexChat.DataCase

  alias WeexChat.Rooms

  describe "channels" do
    alias WeexChat.Rooms.Channel

    import WeexChat.RoomsFixtures

    @invalid_attrs %{name: nil, user_is_guest: nil}

    test "list_channels/0 returns all channels" do
      channel = channel_fixture()
      assert Rooms.list_channels() == [channel]
    end

    test "get_channel!/1 returns the channel with given id" do
      channel = channel_fixture()
      assert Rooms.get_channel!(channel.id) == [channel]
    end

    test "create_channel/1 with valid data creates a channel" do
      valid_attrs = %{name: "some-name", user_is_guest: true}

      assert {:ok, %Channel{} = channel} = Rooms.create_channel(valid_attrs)
      assert channel.name == "some-name"
      assert channel.user_is_guest == true
    end

    test "create_channel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rooms.create_channel(@invalid_attrs)
    end

    test "update_channel/2 with valid data updates the channel" do
      channel = channel_fixture()
      update_attrs = %{name: "some-updated-name", user_is_guest: false}

      assert {:ok, %Channel{} = channel} = Rooms.update_channel(channel, update_attrs)
      assert channel.name == "some-updated-name"
      assert channel.user_is_guest == false
    end

    test "update_channel/2 with invalid data returns error changeset" do
      channel = channel_fixture()
      assert {:error, %Ecto.Changeset{}} = Rooms.update_channel(channel, @invalid_attrs)
      assert [channel] == Rooms.get_channel!(channel.id)
    end

    test "delete_channel/1 deletes the channel" do
      channel = channel_fixture()
      assert {:ok, %Channel{}} = Rooms.delete_channel(channel)
      assert Rooms.get_channel!(channel.id) == []
    end

    test "change_channel/1 returns a channel changeset" do
      channel = channel_fixture()
      assert %Ecto.Changeset{} = Rooms.change_channel(channel)
    end
  end
end
