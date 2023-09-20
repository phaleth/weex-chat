defmodule WeexChat.Rooms do
  @moduledoc """
  The Rooms context.
  """

  import Ecto.Query, warn: false
  alias WeexChat.Repo

  alias WeexChat.Rooms.Channel

  @doc """
  Returns the list of channels.

  ## Examples

      iex> list_channels()
      [%Channel{}, ...]

  """
  def list_channels do
    from(ch in Channel, preload: [:users])
    |> Repo.all()
  end

  @doc """
  Returns the list of of user names for a channel.

  ## Examples

      iex> list_user_names("elixir")
      ["user1", "user2", ...]

  """
  def list_user_names(name) do
    channel =
      from(ch in Channel, where: ch.name == ^name, preload: [:users])
      |> Repo.one()

    if channel && channel.users,
      do: Enum.map(channel.users, & &1.username),
      else: []
  end

  @doc """
  Gets a single channel.

  Raises `Ecto.NoResultsError` if the Channel does not exist.

  ## Examples

      iex> get_channel!(123)
      %Channel{}

      iex> get_channel!(456)
      ** (Ecto.NoResultsError)

      iex> get_channel!("elixir")
      %Channel{}

      iex> get_channel!("gleam")
      ** (Ecto.NoResultsError)

  """
  def get_channel(id) when is_number(id) do
    from(ch in Channel, where: ch.id == ^id, preload: [:users])
    |> Repo.all()
  end

  def get_channel(name) when is_binary(name) do
    from(ch in Channel, where: ch.name == ^name, preload: [:users])
    |> Repo.all()
  end

  @doc """
  Creates a channel.

  ## Examples

      iex> create_channel(%{field: value})
      {:ok, %Channel{}}

      iex> create_channel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_channel(attrs \\ %{}, users \\ []) do
    %Channel{}
    |> Channel.changeset(attrs, users)
    |> Repo.insert()
  end

  @doc """
  Updates a channel.

  ## Examples

      iex> update_channel(channel, %{field: new_value})
      {:ok, %Channel{}}

      iex> update_channel(channel, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_channel(%Channel{} = channel, attrs, users \\ []) do
    channel
    |> Channel.changeset(attrs, users)
    |> Repo.update()
  end

  @doc """
  Deletes a channel.

  ## Examples

      iex> delete_channel(channel)
      {:ok, %Channel{}}

      iex> delete_channel(channel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_channel(%Channel{} = channel) do
    Repo.delete(channel)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking channel changes.

  ## Examples

      iex> change_channel(channel)
      %Ecto.Changeset{data: %Channel{}}

  """
  def change_channel(%Channel{} = channel, attrs \\ %{}, users \\ []) do
    Channel.changeset(channel, attrs, users)
  end
end
