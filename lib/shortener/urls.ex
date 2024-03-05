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
  import Shortener.SlugGenerator

  @doc """
  Creates a short url without an owner.
  """
  def create_short_url(target_url) do
    case %ShortUrl{}
         |> ShortUrl.changeset_without_owner(%{
           target: target_url,
           slug: random_slug()
         })
         |> Repo.insert() do
      {:ok, short_url} ->
        {:ok, short_url}

      {:error, %Ecto.Changeset{errors: [slug: {"has already been taken", _}]}} ->
        create_short_url(target_url)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def get_target_url(slug) do
    case Repo.get_by(ShortUrl, slug: slug) do
      nil -> {:error, :not_found}
      short_url -> {:ok, short_url.target}
    end
  end
end
