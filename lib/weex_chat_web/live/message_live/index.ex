defmodule WeexChatWeb.MessageLive.Index do
  use WeexChatWeb, :live_view

  import WeexChatWeb.Components.Chat

  alias WeexChat.Chat
  alias WeexChat.Chat.Message
  alias WeexChat.Chat.Services.Color

  @one_second 1_000

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :tick, @one_second)
    end

    {:ok,
     socket
     |> assign(loading: !connected?(socket), offset: 0)
     |> stream(:messages, Color.list_messages()), layout: false}
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
    {:noreply,
     socket
     |> assign(offset: offset)
     |> stream(:messages, Color.list_messages())}
  end

  @impl true
  def handle_event("send-message", %{"msg" => msg}, socket) do
    message =
      %Message{
        id: :dom_id,
        user_id: nil,
        from: "Newb",
        content: msg,
        inserted_at: DateTime.utc_now()
      }
      |> Map.put(:from_color, WeexChat.Generators.Color.get("Newb"))

    {:noreply, stream_insert(socket, :messages, message)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.chat loading={assigns.loading} offset={assigns.offset} streams={assigns.streams} />
    """
  end
end
