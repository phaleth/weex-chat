defmodule WeexChatWeb.MessageLive.Index do
  use WeexChatWeb, :live_view

  import WeexChatWeb.Components.Chat

  alias WeexChat.Chat
  alias WeexChat.Chat.Message
  alias WeexChat.Chat.Services.Color

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:loading, !connected?(socket))
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
    |> assign(:page_title, "Listing Messages")
    |> assign(:message, nil)
  end

  @impl true
  def handle_info({WeexChatWeb.MessageLive.FormComponent, {:saved, message}}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    message = Chat.get_message!(id)
    {:ok, _} = Chat.delete_message(message)

    {:noreply, stream_delete(socket, :messages, message)}
  end

  @impl true
  def handle_event("ping", _, socket) do
    {:reply, %{}, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.chat loading={assigns.loading} streams={assigns.streams} />
    """
  end
end
