defmodule WeexChatWeb.Components.Chat do
  @moduledoc false
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr(:loading, :boolean)
  attr(:offset, :integer)
  attr(:streams, :any)

  def chat(assigns) do
    ~H"""
    <div class="flex sm:flex-row flex-col h-screen" phx-hook="timeOffset" id="time-offset">
      <button class="wxch-chans-btn fixed top-2 right-2 sm:hidden text-2xl w-12 h-12 select-none bg-gray-400/40 dark:bg-slate-700/40 hover:bg-slate-800 focus:bg-slate-800 active:bg-slate-900 text-black dark:text-gray-300 flex flex-col justify-center items-center">
        <div class="wxch-chans-ico-hamburger">&#9776;</div>
        <div class="wxch-chans-ico-close hidden">&#128473;</div>
      </button>
      <div class="wxch-chans-list hidden sm:block flex-none w-auto max-h-40 sm:max-h-screen px-1 border-b-2 sm:border-b-0 sm:border-r-2 border-green-500 dark:border-sky-600 overflow-x-auto sm:overflow-x-hidden">
        <div class="grid grid-cols-1">
          <div class="flex gap-0.5">
            <div class="w-6 text-right text-green-400 dark:text-lime-700">1.</div>
            <div class="text-red-800 dark:text-indigo-600">network</div>
          </div>
          <div class="flex gap-0.5">
            <div class="w-6 text-right text-green-400 dark:text-lime-700"></div>
            <div class=" text-gray-700 dark:text-gray-400">weexchat</div>
          </div>
          <div class="flex gap-5">
            <div class="w-6 text-right text-green-400 dark:text-lime-700">2.</div>
            <div>#redacted</div>
          </div>
          <div class="flex gap-5">
            <div class="w-6 text-right text-green-400 dark:text-lime-700">3.</div>
            <div>#redacted</div>
          </div>
          <div class="flex gap-5">
            <div class="w-6 text-right text-green-400 dark:text-lime-700">4.</div>
            <div class="text-gray-700 dark:text-gray-400">#redacted</div>
          </div>
          <div class="flex gap-5">
            <div class="w-6 text-right text-green-400 dark:text-lime-700">5.</div>
            <div class="text-gray-700 dark:text-gray-400">#redacted</div>
          </div>
          <div class="flex gap-5">
            <div class="w-6 text-right text-green-400 dark:text-lime-700">6.</div>
            <div>#redacted</div>
          </div>
          <div class="flex gap-5">
            <div class="w-6 text-right text-green-400 dark:text-lime-700">7.</div>
            <div>#redacted</div>
          </div>
          <div class="flex gap-5">
            <div class="w-6 text-right text-green-400 dark:text-lime-700">8.</div>
            <div>#redacted</div>
          </div>
          <div class="flex gap-5 bg-green-500 dark:bg-blue-700 text-gray-700 dark:text-gray-400">
            <div class="w-6 text-right text-green-400 dark:text-lime-700">9.</div>
            <div>#lfe</div>
          </div>
          <div class="flex gap-5">
            <div class="w-6 text-right text-green-400 dark:text-lime-700">10.</div>
            <div>#redacted</div>
          </div>
          <div class="flex gap-5">
            <div class="w-6 text-right text-green-400 dark:text-lime-700">11.</div>
            <div class="text-gray-700 dark:text-gray-400">#redacted</div>
          </div>
          <div class="flex gap-5">
            <div class="w-6 text-right text-green-400 dark:text-lime-700">12.</div>
            <div>#redacted</div>
          </div>
        </div>
      </div>
      <div class="flex-auto w-full px-1">
        <div class="flex flex-col h-full">
          <div class="flex-none h-5 text-ellipsis overflow-hidden">
            <div>
              Little Fighter Empire | https://discord.gg/MWrHgT4h | https://lf-empire.de/forum/
            </div>
          </div>
          <div class="flex-auto h-full overflow-x-auto">
            <div
              class="grid grid-cols-[max-content_max-content_max-content_auto]"
              phx-update="stream"
              id="messages-container"
            >
              <%= for {id, message} <- @streams.messages do %>
                <div class="pr-1">
                  <%= if !@loading do %>
                    <span>
                      <%= DateTime.from_naive!(message.inserted_at, "Etc/UTC")
                      |> DateTime.add(@offset, :hour)
                      |> Calendar.strftime("%H:%M") %>
                    </span>
                  <% end %>
                </div>
                <div
                  class={"px-1 text-right" <> if(message.from == "ℹ", do: " pr-3", else: "")}
                  style={"color: #{message.from_color};"}
                >
                  <%= message.from %>
                </div>
                <div class="px-1 text-green-600 dark:text-lime-400">╡</div>
                <div class="flex group" id={id}>
                  <span class="flex-none"><%= message.content %></span>
                  <span
                    id={"mod-#{id}"}
                    phx-hook="modMsg"
                    class="flex-none ml-2 hidden group-hover:inline cursor-pointer text-lime-200"
                  >
                    &#128393;
                  </span>
                  <span
                    id={"del-#{id}"}
                    phx-click={JS.push("del-msg", value: %{id: id})}
                    phx-hook="delMsg"
                    class="flex-none ml-2 hidden group-hover:inline cursor-pointer"
                  >
                    &#10060;
                  </span>
                </div>
              <% end %>
            </div>
          </div>
          <div class="flex-none h-12">
            <div class="h-5 text-ellipsis overflow-hidden">
              <span class="text-purple-700 dark:text-cyan-700">[</span><span :if={@loading}>--:--</span><span
                :if={!@loading}
                phx-hook="currentTime"
                id="current-time"
              ><%= DateTime.utc_now() |> DateTime.add(@offset, :hour)
              |> Calendar.strftime("%H:%M") %></span><span class="text-purple-700 dark:text-cyan-700">]</span> <span class="text-purple-700 dark:text-cyan-700">[</span>13<span class="text-purple-700 dark:text-cyan-700">]</span> <span class="text-purple-700 dark:text-cyan-700">[</span>irc<span class="text-purple-700 dark:text-cyan-700">/</span>libera<span class="text-purple-700 dark:text-cyan-700">]</span>
              <span class="text-green-600 dark:text-yellow-200">13</span><span class="text-purple-700 dark:text-cyan-700">:</span><span class="text-green-600 dark:text-lime-400">#lfe</span><span class="text-purple-700 dark:text-cyan-700">(</span>+nt<span class="text-purple-700 dark:text-cyan-700">){</span>6<span class="text-purple-700 dark:text-cyan-700">} [</span>Lag:
              <span class="text-green-600 dark:text-yellow-200" id="ping" phx-hook="ping">-----</span><span class="text-purple-700 dark:text-cyan-700">]</span>
            </div>
            <div class="flex">
              <span class="flex-none text-purple-700 dark:text-cyan-700">[</span><span class="text-indigo-500 dark:text-teal-500">phaleth</span><span class="text-purple-700 dark:text-cyan-700">(</span>Ziw<span class="text-purple-700 dark:text-cyan-700">)]</span>
              <form class="flex-auto" id="msg-form" phx-submit="new-msg">
                <input
                  class="wxch-remove-box-shadow pt-0 pb-1.5 px-1.5 h-5 w-full border-none bg-gray-200 dark:bg-black text-black dark:text-gray-300 placeholder-gray-600 dark:placeholder-gray-400 font-mono text-sm"
                  aria-label="New message"
                  type="text"
                  id="msg"
                  name="msg"
                  placeholder="Type here..."
                  phx-hook="msgSubmit"
                />
              </form>
            </div>
          </div>
        </div>
      </div>
      <div class="wxch-users-list hidden sm:block flex-none w-auto max-h-40 sm:max-h-screen px-1 border-t-2 sm:border-t-0 sm:border-l-2 border-green-500 dark:border-sky-600 overflow-x-auto sm:overflow-x-hidden">
        <div class="flex">
          <div class="text-green-400 dark:text-lime-700">@</div>
          <div>ChanServ</div>
        </div>
        <div class="flex gap-4">
          <div></div>
          <div>redacted</div>
        </div>
        <div class="flex gap-4">
          <div></div>
          <div>redacted</div>
        </div>
        <div class="flex gap-4">
          <div></div>
          <div>redacted</div>
        </div>
        <div class="flex gap-4">
          <div></div>
          <div>phaleth</div>
        </div>
        <div class="flex gap-4">
          <div></div>
          <div>redacted</div>
        </div>
        <div class="flex gap-4">
          <div></div>
          <div>redacted</div>
        </div>
        <div class="flex gap-4">
          <div></div>
          <div>redacted</div>
        </div>
        <div class="flex gap-4">
          <div></div>
          <div>redacted</div>
        </div>
      </div>
      <button class="wxch-users-btn fixed bottom-2 right-2 sm:hidden text-2xl w-12 h-12 select-none bg-gray-400/40 dark:bg-slate-700/40 hover:bg-slate-800 focus:bg-slate-800 active:bg-slate-900 text-black dark:text-gray-300 flex flex-col justify-center items-center">
        <div class="wxch-users-ico-hamburger">&#9776;</div>
        <div class="wxch-users-ico-close hidden">&#128473;</div>
      </button>
    </div>
    """
  end
end
