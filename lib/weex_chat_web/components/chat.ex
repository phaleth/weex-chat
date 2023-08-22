defmodule WeexChatWeb.Components.Chat do
  use Phoenix.Component

  attr :streams, :any

  def chat(assigns) do
    ~H"""
    <div class="flex sm:flex-row flex-col h-screen">
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
          <div class="flex-none h-6 text-ellipsis overflow-hidden">
            <div>
              Little Fighter Empire | https://discord.gg/MWrHgT4h | https://lf-empire.de/forum/
            </div>
          </div>
          <div class="flex-auto h-full">
            <div class="grid grid-cols-[max-content_max-content_max-content_auto]">
              <%= for {id, message} <- @streams.messages do %>
                <div class="px-1"><%= Calendar.strftime(message.inserted_at, "%H:%M") %></div>
                <div
                  class={"px-1 text-right" <> if(message.from == "ℹ", do: " pr-3", else: "")}
                  style={"color: #{message.from_color};"}
                >
                  <%= message.from %>
                </div>
                <div class="px-1 text-green-600 dark:text-lime-400">╡</div>
                <div id={id}><%= message.content %></div>
              <% end %>
            </div>
          </div>
          <div class="flex-none h-12">
            <div class="h-6 text-ellipsis overflow-hidden">
              <span class="text-purple-700 dark:text-cyan-700">[</span>23:45<span class="text-purple-700 dark:text-cyan-700">]</span> <span class="text-purple-700 dark:text-cyan-700">[</span>13<span class="text-purple-700 dark:text-cyan-700">]</span> <span class="text-purple-700 dark:text-cyan-700">[</span>irc<span class="text-purple-700 dark:text-cyan-700">/</span>libera<span class="text-purple-700 dark:text-cyan-700">]</span>
              <span class="text-green-600 dark:text-yellow-200">13</span><span class="text-purple-700 dark:text-cyan-700">:</span><span class="text-green-600 dark:text-lime-400">#lfe</span><span class="text-purple-700 dark:text-cyan-700">(</span>+nt<span class="text-purple-700 dark:text-cyan-700">){</span>6<span class="text-purple-700 dark:text-cyan-700">} [</span>Lag:
              <span class="text-green-600 dark:text-yellow-200" id="ping" phx-hook="ping">-----</span>
              <span class="text-purple-700 dark:text-cyan-700">]</span>
            </div>
            <div>
              <span class="text-purple-700 dark:text-cyan-700">[</span><span class="text-indigo-500 dark:text-teal-500">phaleth</span><span class="text-purple-700 dark:text-cyan-700">(</span>Ziw<span class="text-purple-700 dark:text-cyan-700">)]</span>
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
