defmodule WeexChatWeb.MessageLive.Index do
  use WeexChatWeb, :live_view

  import WeexChatWeb.Components.Chat

  alias WeexChat.Chat
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
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Message")
    |> assign(:message, Chat.get_message!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Message")
    |> assign(:message, %Message{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "weexchat")
    |> assign(:message, nil)
  end

  @impl true
  def handle_info({WeexChatWeb.MessageLive.FormComponent, {:saved, message}}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
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
      if String.starts_with?(msg, "/create ") do
        exec_create_command(socket, msg, user_id)
      else
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

    change_channel =
      &cond do
        &1.active -> Map.put(&1, :active, false)
        &1.id === id -> Map.put(&1, :active, true)
        true -> &1
      end

    channels =
      if Enum.find(channels, & &1.active).id === id do
        channels
      else
        Enum.map(channels, &change_channel.(&1))
      end

    {:noreply, socket |> assign(:channels, channels) |> stream(:messages, [], reset: true)}
  end

  defp create_channel_by_name(socket, channel_name, user_id) do
    case Rooms.create_channel(%{
           name: channel_name,
           creator_id: user_id,
           user_is_guest: is_nil(user_id)
         }) do
      {:ok, channel} ->
        Ecto.Adapters.SQL.query(
          WeexChat.Repo,
          "INSERT INTO users_channels (user_id, channel_id) VALUES (#{user_id}, #{channel.id})"
        )

        channels = socket.assigns.channels

        socket
        |> assign(:channels, channels ++ [Map.put(channel, :index, length(channels))])
        |> push_event("hooray", %{})

      {:error, %Ecto.Changeset{} = changeset} ->
        {_, error} = List.first(changeset.errors)
        socket |> put_flash(:error, error)
    end
  end

  defp exec_create_command(socket, msg, user_id) do
    case msg do
      "/create " <> channel ->
        words = String.split(channel, " ", trim: true)

        if length(words) === 1 do
          create_channel_by_name(socket, List.first(words), user_id)
        end

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
