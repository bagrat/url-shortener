defmodule Shortener.SlugGenerator do
  @doc """
  Generates a random slug.
  """
  def random_slug() do
    :crypto.strong_rand_bytes(4)
    |> Base.url_encode64()
    |> binary_part(0, 6)
  end
end

defmodule Shortener.Urls do
  @moduledoc """
  The Urls context.
  """

  import Ecto.Query, warn: false
  alias Shortener.Repo

  alias Shortener.Urls.ShortUrl
  alias Shortener.Accounts.User

  import Shortener.SlugGenerator

  @doc """
  Creates a short url without an owner.
  """
  def create_short_url(target_url, owner \\ nil) do
    attrs = %{
      target: target_url,
      slug: random_slug()
    }

    attrs =
      case owner do
        nil -> attrs
        owner -> Map.put(attrs, :owner_id, owner.id)
      end

    case ShortUrl.create_changeset(%ShortUrl{}, attrs)
         |> Repo.insert() do
      {:ok, short_url} ->
        {:ok, short_url}

      {:error, %Ecto.Changeset{errors: [slug: {"has already been taken", _}]}} ->
        create_short_url(target_url)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Gets the target url for the given slug.
  """
  def get_short_url(slug) do
    case Repo.get_by(ShortUrl, slug: slug) do
      nil -> {:error, :not_found}
      short_url -> {:ok, short_url}
    end
  end

  @doc """
  Increases visits count for the given short URL.
  """
  def increment_visits(%ShortUrl{} = short_url) do
    increment_query =
      from ShortUrl,
        where: [id: ^short_url.id],
        update: [inc: [visits: +1]]

    Ecto.Multi.new()
    |> Ecto.Multi.update_all(:increment, increment_query, [])
    |> Repo.transaction()
  end

  @doc """
  Return the list of URLs for the given user.
  """
  def list_user_urls(%User{id: id}) do
    Repo.all(from(s in ShortUrl, where: s.owner_id == ^id, order_by: [desc: s.inserted_at]))
  end

  @doc """
  Gets a single short_url.
  """
  def get_short_url!(id), do: Repo.get!(ShortUrl, id)

  @doc """
  Create a changeset validating the slug.
  """
  def change_slug(%ShortUrl{} = short_url, attrs) do
    short_url
    |> ShortUrl.validate_slug(attrs)
  end

  @doc """
  Deletes a short_url.
  """
  def delete_short_url(%ShortUrl{} = short_url) do
    Repo.delete(short_url)
  end

  @doc """
  Updates a short_url.

  ## Examples

      iex> update_short_url(short_url, %{field: new_value})
      {:ok, %ShortUrl{}}

      iex> update_short_url(short_url, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_short_url(%ShortUrl{} = short_url, attrs) do
    short_url
    |> ShortUrl.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking short_url changes.

  ## Examples

      iex> change_short_url(short_url)
      %Ecto.Changeset{data: %ShortUrl{}}

  """
  def change_short_url(%ShortUrl{} = short_url, attrs \\ %{}) do
    ShortUrl.update_changeset(short_url, attrs)
  end
end
