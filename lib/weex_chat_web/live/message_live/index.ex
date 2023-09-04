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

    {user_id, user_name} = get_user_id_and_name(socket.assigns)

    {:ok,
     socket
     |> assign(
       loading: !is_connected,
       offset: 0,
       user_id: user_id,
       user_name: user_name,
       active_channel_name: "n/a",
       channels: [],
       user_names: []
     )
     |> stream(:messages, []), layout: false}
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

    channels = setup_channels(socket.assigns)
    channel_name = get_active_channel_name(channels)

    {:noreply,
     socket
     |> assign(
       newest_message_id: newest_message_id,
       active_channel_name: channel_name,
       channels: channels,
       user_names: WeexChat.Rooms.list_user_names(channel_name)
     )
     |> stream(:messages, messages)}
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
    user_id = socket.assigns.user_id
    user_name = socket.assigns.user_name

    socket =
      cond do
        String.starts_with?(msg, "/create ") ->
          exec_create_command(socket, msg, user_id)

        String.starts_with?(msg, "/join ") ->
          exec_join_command(socket, msg, user_id)

        String.starts_with?(msg, "/leave ") ->
          exec_leave_command(socket, msg, user_id)

        true ->
          new_msg_id = socket.assigns.newest_message_id + 1

          message =
            %Message{
              id: new_msg_id,
              user_id: user_id,
              from: user_name,
              content: msg,
              inserted_at: DateTime.utc_now()
            }
            |> Map.put(:from_color, WeexChat.Generators.Color.get(user_name))

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

    channel_name = get_active_channel_name(channels)

    {:noreply,
     socket
     |> push_event("clear-chat", %{})
     |> assign(
       active_channel_name: channel_name,
       channels: channels,
       user_names: WeexChat.Rooms.list_user_names(channel_name)
     )
     |> stream(:messages, [], reset: true)}
  end

  defp get_user_id_and_name(assigns) do
    user = assigns[:current_user]

    if user,
      do: {user.id, user.username},
      else: {nil, "Anonymous"}
  end

  defp get_active_channel_name(channels) do
    if Enum.empty?(channels),
      do: "n/a",
      else: Enum.find(channels, & &1.active).name
  end

  defp setup_channels(assigns) do
    first_channel_be_active =
      &if &1 === 0,
        do: Map.put(&2, :active, true),
        else: &2

    user_id = assigns.user_id

    if user_id,
      do:
        Accounts.get_user!(user_id).channels
        |> Enum.with_index()
        |> Enum.map(fn {channel, idx} ->
          Map.put(
            first_channel_be_active.(idx, channel),
            :index,
            idx
          )
        end),
      else: []
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
        channels = activate_channel(socket.assigns.channels, channel, user_id)
        channel_name = get_active_channel_name(channels)

        socket
        |> assign(
          active_channel_name: channel_name,
          channels: channels,
          user_names: WeexChat.Rooms.list_user_names(channel_name)
        )
        |> push_event("hooray", %{})

      {:error, %Ecto.Changeset{} = changeset} ->
        {_, error} = List.first(changeset.errors)
        socket |> put_flash(:error, elem(error, 0))
    end
  end

  defp join_channel_by_name(socket, channel_name, user_id) do
    channel = Rooms.get_channel!(channel_name)
    channels = activate_channel(socket.assigns.channels, channel, user_id)

    socket
    |> assign(
      active_channel_name: channel_name,
      channels: channels,
      user_names: WeexChat.Rooms.list_user_names(channel_name)
    )
  end

  defp leave_channel_by_name(socket, channel_name, user_id) do
    channel = Rooms.get_channel!(channel_name)

    Ecto.Adapters.SQL.query(
      WeexChat.Repo,
      "DELETE FROM users_channels WHERE user_id = #{user_id} AND channel_id = #{channel.id}"
    )

    channels = setup_channels(socket.assigns)
    channel_name = get_active_channel_name(channels)

    socket
    |> assign(
      active_channel_name: channel_name,
      channels: channels,
      user_names: WeexChat.Rooms.list_user_names(channel_name)
    )
  end

  defp maybe_exec_channel_command(socket, channel, user_id, callback) do
    words = String.split(channel, " ", trim: true)

    if length(words) === 1,
      do: callback.(socket, List.first(words), user_id),
      else: socket |> put_flash(:error, "Provide just a single argument")
  end

  defp exec_create_command(socket, msg, user_id) do
    case msg do
      "/create " <> channel ->
        maybe_exec_channel_command(socket, channel, user_id, &create_channel_by_name/3)

      _ ->
        socket |> put_flash(:error, "Incorrect create command call.")
    end
  end

  defp exec_join_command(socket, msg, user_id) do
    case msg do
      "/join " <> channel ->
        maybe_exec_channel_command(socket, channel, user_id, &join_channel_by_name/3)

      _ ->
        socket |> put_flash(:error, "Incorrect join command call.")
    end
  end

  defp exec_leave_command(socket, msg, user_id) do
    case msg do
      "/leave " <> channel ->
        maybe_exec_channel_command(socket, channel, user_id, &leave_channel_by_name/3)

      _ ->
        socket |> put_flash(:error, "Incorrect leave command call.")
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
      user_name={assigns.user_name}
      active_channel_name={assigns.active_channel_name}
      user_names={assigns.user_names}
    />
    """
  end
end
