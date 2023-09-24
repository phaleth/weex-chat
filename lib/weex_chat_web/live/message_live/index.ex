defmodule WeexChatWeb.MessageLive.Index do
  use WeexChatWeb, :live_view

  import WeexChatWeb.Components.Chat

  alias WeexChat.Chat.Message
  alias WeexChat.Chat.Services.Color
  alias WeexChat.Accounts
  alias WeexChat.Rooms
  alias WeexChatWeb.Presence
  alias WeexChat.Accounts.User
  alias WeexChat.Repo
  alias WeexChat.Generators

  @one_second 1_000
  @default_name "n/a"
  @user_list "userlist"
  @messages "messages"
  @anon_user_name "Anonymous"

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
       active_channel_name: @default_name,
       channels: [],
       user_names: [],
       channel_index: 0,
       user_count: 0
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
  def handle_info(
        %Phoenix.Socket.Broadcast{topic: @messages, event: "new", payload: message},
        socket
      ) do
    socket =
      if is_nil(message),
        do: socket,
        else: stream_insert(socket, :messages, message)

    {:noreply,
     socket
     |> push_event("scroll", %{})}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    user_names = current_channel_user_names(socket.assigns.active_channel_name)

    {:noreply,
     socket
     |> assign(user_names: user_names, user_count: length(user_names))}
  end

  @impl true
  def handle_event("setup-lists", _params, socket) do
    Presence.track(self(), @user_list, socket.id, %{
      user: get_user(socket)
    })

    WeexChatWeb.Endpoint.subscribe(@user_list)

    messages = Color.list_messages()
    last_msg = List.last(messages)

    channels = setup_channels(socket.assigns)
    channel = get_active_channel(channels)
    channel_name = get_active_channel_name(channel)

    WeexChatWeb.Endpoint.subscribe(@messages)

    user_names = current_channel_user_names(channel_name)

    {:noreply,
     socket
     |> assign(
       newest_message_id: if(is_nil(last_msg), do: 0, else: last_msg.id),
       active_channel_name: channel_name,
       channels: channels,
       user_names: user_names,
       channel_index: get_active_channel_index(channel),
       user_count: length(user_names)
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
  def handle_event("new-msg", %{"msg" => content}, socket) do
    user_id = socket.assigns.user_id
    user_name = socket.assigns.user_name

    new_msg_socket = fn new_msg_id, active_channel ->
      active_channel_name = active_channel.name

      message =
        if String.length(content) > 0,
          do: %Message{
            id: new_msg_id,
            user_id: user_id,
            from: user_name,
            content: content,
            channel_name: active_channel_name,
            from_color: Generators.Color.get_hsl(user_name, get_phx_ref(socket)),
            inserted_at: DateTime.utc_now()
          },
          else: nil

      WeexChatWeb.Endpoint.broadcast_from(self(), @messages, "new", message)

      socket =
        if is_nil(message),
          do: socket,
          else: stream_insert(socket, :messages, message)

      socket
      |> assign(:newest_message_id, new_msg_id)
    end

    socket =
      cond do
        String.starts_with?(content, "/create ") ->
          exec_create_command(socket, content, user_id)

        String.starts_with?(content, "/join ") ->
          exec_join_command(socket, content, user_id)

        String.starts_with?(content, "/leave ") ->
          exec_leave_command(socket, content, user_id)

        true ->
          new_msg_id = socket.assigns.newest_message_id + 1
          active_channel = Enum.find(socket.assigns.channels, & &1.active)

          if is_nil(active_channel) do
            socket
          else
            new_msg_socket.(new_msg_id, active_channel)
          end
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("mod-msg", %{"id" => _id, "value" => _msg}, socket) do
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

    previously_active_channel = Enum.find(channels, & &1.active)

    channels =
      if previously_active_channel.id === id do
        channels
      else
        change_channel(channels, id)
      end

    channel = get_active_channel(channels)
    channel_name = get_active_channel_name(channel)

    user_names = current_channel_user_names(channel_name)

    {:noreply,
     socket
     |> push_event("change-chan", %{channel: channel_name})
     |> assign(
       active_channel_name: channel_name,
       channels: channels,
       user_names: user_names,
       channel_index: get_active_channel_index(channel),
       user_count: length(user_names)
     )
     |> stream(:messages, [], reset: true)}
  end

  defp get_phx_ref(socket) do
    "phx-" <> phx_ref = socket.id
    phx_ref
  end

  defp get_user(socket) do
    user = socket.assigns[:current_user]

    if user,
      do:
        Repo.preload(user, :channels)
        |> Map.put(:from_color, Generators.Color.get_hsl(user.username, nil)),
      else: %User{
        username: @anon_user_name,
        channels: [],
        from_color: Generators.Color.get_hsl(@anon_user_name, get_phx_ref(socket))
      }
  end

  defp get_user_id_and_name(assigns) do
    user = assigns[:current_user]

    if user,
      do: {user.id, user.username},
      else: {nil, @anon_user_name}
  end

  defp get_active_channel(channels) do
    Enum.find(channels, & &1.active)
  end

  defp get_active_channel_index(active_channel) do
    if is_nil(active_channel),
      do: 0,
      else: active_channel.index
  end

  defp get_active_channel_name(active_channel) do
    if is_nil(active_channel),
      do: @default_name,
      else: active_channel.name
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
    channel = List.first(Rooms.get_channel(channel_name))

    if is_nil(channel) do
      case Rooms.create_channel(%{
             name: channel_name,
             creator_id: user_id,
             user_is_guest: is_nil(user_id)
           }) do
        {:ok, channel} ->
          channels = activate_channel(socket.assigns.channels, channel, user_id)
          channel = get_active_channel(channels)
          channel_name = get_active_channel_name(channel)

          user_names = current_channel_user_names(channel_name)

          socket
          |> assign(
            active_channel_name: channel_name,
            channels: channels,
            user_names: user_names,
            channel_index: get_active_channel_index(channel),
            user_count: length(user_names)
          )
          |> push_event("hooray", %{})

        {:error, %Ecto.Changeset{} = changeset} ->
          {_, error} = List.first(changeset.errors)
          socket |> put_flash(:error, elem(error, 0))
      end
    else
      join_channel_by_name(socket, channel_name, user_id)
    end
  end

  defp join_channel_by_name(socket, channel_name, user_id) do
    channel = List.first(Rooms.get_channel(channel_name))

    if is_nil(channel) do
      socket
    else
      channels =
        activate_channel(
          socket.assigns.channels,
          channel,
          user_id
        )

      channel = get_active_channel(channels)

      maybe_update_anon_user_chans(user_id, socket.id, fn chans -> chans ++ [channel] end)

      user_names = current_channel_user_names(channel_name)

      socket
      |> assign(
        active_channel_name: channel_name,
        channels: channels,
        user_names: user_names,
        channel_index: get_active_channel_index(channel),
        user_count: length(user_names)
      )
    end
  end

  defp leave_channel_by_name(socket, channel_name, user_id) do
    channel = List.first(Rooms.get_channel(channel_name))

    if is_nil(channel) do
      socket
    else
      Ecto.Adapters.SQL.query(
        WeexChat.Repo,
        "DELETE FROM users_channels WHERE user_id = #{user_id} AND channel_id = #{channel.id}"
      )

      channels = setup_channels(socket.assigns)
      channel = get_active_channel(channels)

      maybe_update_anon_user_chans(user_id, socket.id, fn chans -> List.delete(chans, channel) end)

      channel_name = get_active_channel_name(channel)

      user_names = current_channel_user_names(channel_name)

      socket
      |> assign(
        active_channel_name: channel_name,
        channels: channels,
        user_names: user_names,
        channel_index: get_active_channel_index(channel),
        user_count: length(user_names)
      )
    end
  end

  defp maybe_update_anon_user_chans(user_id, socket_id, callback) do
    if is_nil(user_id) do
      item =
        Presence.get_by_key(@user_list, socket_id)[:metas]
        |> List.first()

      anon_user =
        item
        |> Map.get(:user)
        |> Map.update(:channels, [], callback)

      metas =
        item
        |> Map.put(:user, anon_user)

      Presence.update(self(), @user_list, socket_id, metas)
    end
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

  defp users_from_presence(channel_name) do
    Presence.list(@user_list)
    |> Enum.map(fn {_, data} ->
      entry = data[:metas] |> List.first()
      entry.user
    end)
    |> Enum.filter(fn user ->
      Enum.any?(Enum.map(user.channels, &(&1.name === channel_name)))
    end)
  end

  defp current_channel_user_names(channel_name) do
    present_users = users_from_presence(channel_name)

    anon_users =
      Enum.filter(present_users, &(&1.username === @anon_user_name))
      |> Enum.map(& &1.username)

    logged_in_users =
      MapSet.intersection(
        Enum.into(Enum.map(present_users, & &1.username), MapSet.new()),
        Enum.into(WeexChat.Rooms.list_user_names(channel_name), MapSet.new())
      )
      |> MapSet.to_list()

    Enum.sort(anon_users ++ logged_in_users)
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
      channel_index={assigns.channel_index}
      user_count={assigns.user_count}
      current_user={assigns.current_user}
    />
    """
  end
end
