defmodule WeexChat.Generators.Color do
  @moduledoc false
  def get_hsl(text, phx_ref) do
    case text do
      "ℹ" ->
        "#e5e7eb"

      "-->" ->
        "#90ee90"

      "<--" ->
        "#8b0000"

      "" ->
        "#fff"

      "Anonymous" ->
        if(is_nil(phx_ref),
          do: text,
          else: phx_ref
        )
        |> apply_hue()

      _ ->
        apply_hue(text)
    end
  end

  def apply_hue(text) do
    hue =
      to_charlist(text)
      |> Enum.sum()
      |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
