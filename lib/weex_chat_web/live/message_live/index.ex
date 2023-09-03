defmodule WeexChatWeb.MessageLive.Index do
  use WeexChatWeb, :live_view

  import WeexChatWeb.Components.Chat

  alias WeexChat.Chat.Message
  alias WeexChat.Chat.Services.Color
  alias WeexChat.Accounts
  alias WeexChat.Rooms

  @one_second 1_000

  @impl true
  def mount(_params, _session, socket) do
    is_connected = connected?(socket)

    if is_connected, do: Process.send_after(self(), :tick, @one_second)

    {:ok,
     socket
     |> assign(loading: !is_connected, offset: 0)
     |> stream(:messages, [])
     |> assign(:channels, []), layout: false}
  end

  @impl true
  def handle_params(_params, _url, %{assigns: %{live_action: :index}} = socket) do
    {:noreply, socket |> assign(:page_title, "weexchat")}
  end

  @impl true
  def handle_info(:tick, socket) do
    time =
      DateTime.utc_now()
      |> DateTime.add(socket.assigns.offset, :hour)
      |> Calendar.strftime("%H:%M")

    Process.send_after(self(), :tick, @one_second)

    {:noreply,
     socket
     |> push_event("tick", %{time: time})}
  end

  @impl true
  def handle_event("setup-lists", _params, socket) do
    messages = Color.list_messages()
    last_msg = List.last(messages)
    newest_message_id = if is_nil(last_msg), do: 0, else: last_msg.id

    user = socket.assigns[:current_user]

    first_channel_be_active =
      &if &1 === 0,
        do: Map.put(&2, :active, true),
        else: &2

    channels =
      if user,
        do:
          Accounts.get_user!(user.id).channels
          |> Enum.with_index()
          |> Enum.map(fn {channel, idx} ->
            Map.put(
              first_channel_be_active.(idx, channel),
              :index,
              idx
            )
          end),
        else: []

    {:noreply,
     socket
     |> assign(:newest_message_id, newest_message_id)
     |> stream(:messages, messages)
     |> assign(:channels, channels)}
  end

  @impl true
  def handle_event("ping", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("time-zone", %{"offset" => offset}, socket) do
    {:noreply,
     socket
     |> assign(:offset, offset)}
  end

  @impl true
  def handle_event("new-msg", %{"msg" => msg}, socket) do
    user = socket.assigns[:current_user]

    {user_id, username} =
      if user,
        do: {user.id, user.username},
        else: {nil, "Anonymous"}

    socket =
      cond do
        String.starts_with?(msg, "/create ") ->
          exec_create_command(socket, msg, user_id)

        String.starts_with?(msg, "/join ") ->
          exec_join_command(socket, msg, user_id)

        true ->
          new_msg_id = socket.assigns.newest_message_id + 1

          message =
            %Message{
              id: new_msg_id,
              user_id: user_id,
              from: username,
              content: msg,
              inserted_at: DateTime.utc_now()
            }
            |> Map.put(:from_color, WeexChat.Generators.Color.get(username))

          socket
          |> assign(:newest_message_id, new_msg_id)
          |> stream_insert(:messages, message)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("mod-msg", %{"id" => "mod-messages-" <> id, "value" => msg}, socket) do
    IO.puts(id)
    IO.puts(msg)
    {:noreply, socket}
  end

  @impl true
  def handle_event("msg-mod-submit", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("del-msg", %{"id" => id}, socket) do
    {:noreply, socket |> stream_delete_by_dom_id(:messages, id)}
  end

  @impl true
  def handle_event("activate-chan", %{"id" => id}, socket) do
    channels = socket.assigns.channels

    channels =
      if Enum.find(channels, & &1.active).id === id,
        do: channels,
        else: change_channel(channels, id)

    {:noreply, socket |> assign(:channels, channels) |> stream(:messages, [], reset: true)}
  end

  defp change_channel(channels, target_id) do
    Enum.map(
      channels,
      &cond do
        &1.active -> Map.put(&1, :active, false)
        &1.id === target_id -> Map.put(&1, :active, true)
        true -> &1
      end
    )
  end

  defp activate_channel(channels, channel, user_id) do
    Ecto.Adapters.SQL.query(
      WeexChat.Repo,
      "INSERT INTO users_channels (user_id, channel_id) VALUES (#{user_id}, #{channel.id})"
    )

    (channels ++ [Map.put(channel, :index, length(channels))])
    |> change_channel(channel.id)
  end

  defp create_channel_by_name(socket, channel_name, user_id) do
    case Rooms.create_channel(%{
           name: channel_name,
           creator_id: user_id,
           user_is_guest: is_nil(user_id)
         }) do
      {:ok, channel} ->
        socket
        |> assign(:channels, activate_channel(socket.assigns.channels, channel, user_id))
        |> push_event("hooray", %{})

      {:error, %Ecto.Changeset{} = changeset} ->
        {_, error} = List.first(changeset.errors)
        socket |> put_flash(:error, error)
    end
  end

  defp join_channel_by_name(socket, channel_name, user_id) do
    channel = Rooms.get_channel!(channel_name)

    socket
    |> assign(:channels, activate_channel(socket.assigns.channels, channel, user_id))
  end

  defp maybe_exec_channel_command(socket, channel, user_id, callback) do
    words = String.split(channel, " ", trim: true)

    if length(words) === 1, do: callback.(socket, List.first(words), user_id)
  end

  defp exec_create_command(socket, msg, user_id) do
    case msg do
      "/create " <> channel ->
        maybe_exec_channel_command(socket, channel, user_id, &create_channel_by_name/3)

      _ ->
        socket
    end
  end

  defp exec_join_command(socket, msg, user_id) do
    case msg do
      "/join " <> channel ->
        maybe_exec_channel_command(socket, channel, user_id, &join_channel_by_name/3)

      _ ->
        socket
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.chat
      loading={assigns.loading}
      offset={assigns.offset}
      streams={assigns.streams}
      channels={assigns.channels}
    />
    """
  end
end
