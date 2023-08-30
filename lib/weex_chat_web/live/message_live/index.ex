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

    if is_connected do
      Process.send_after(self(), :tick, @one_second)
    end

    user = socket.assigns[:current_user]

    channels =
      if user,
        do: Accounts.get_user!(user.id).channels,
        else: []

    {:ok,
     socket
     |> assign(loading: !is_connected, offset: 0)
     |> stream(:messages, [])
     |> stream(:channels, channels), layout: false}
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
  def handle_event("delete", %{"id" => id}, socket) do
    message = Chat.get_message!(id)
    {:ok, _} = Chat.delete_message(message)

    {:noreply, stream_delete(socket, :messages, message)}
  end

  @impl true
  def handle_event("ping", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("time-zone", %{"offset" => offset}, socket) do
    messages = Color.list_messages()
    last_msg = List.last(messages)
    newest_message_id = if is_nil(last_msg), do: 0, else: last_msg.id

    {:noreply,
     socket
     |> assign(offset: offset, newest_message_id: newest_message_id)
     |> stream(:messages, messages)}
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
  def handle_event("mod-msg", %{"id" => "mod-messages-" <> id, "msg" => msg}, socket) do
    IO.puts(id)
    IO.puts(msg)
    {:noreply, socket}
  end

  @impl true
  def handle_event("del-msg", %{"id" => "messages-" <> id}, socket) do
    IO.puts(id)
    {:noreply, socket}
  end

  defp create_channel_by_name(socket, channel_name, user_id) do
    case Rooms.create_channel(%{
           name: channel_name,
           user_is_guest: is_nil(user_id)
         }) do
      {:ok, channel} ->
        socket
        |> stream_insert(:channels, channel)

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
    <.chat loading={assigns.loading} offset={assigns.offset} streams={assigns.streams} />
    """
  end
end
