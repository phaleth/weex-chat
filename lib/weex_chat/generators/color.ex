defmodule WeexChat.Generators.Color do
  def get(text) do
    case text do
      "ℹ" -> "#e5e7eb"
      "-->" -> "#90ee90"
      "<--" -> "#8b0000"
      "" -> "#fff"
      _ ->
        hue = to_charlist(text) |> Enum.sum() |> rem(360)
        "hsl(#{hue}, 70%, 40%)"
    end
  end
end
