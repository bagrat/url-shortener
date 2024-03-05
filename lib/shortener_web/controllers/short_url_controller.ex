defmodule ShortenerWeb.ShortUrlController do
  use ShortenerWeb, :controller

  action_fallback ShortenerWeb.FallbackController

  alias Shortener.Urls

  def go_to_target(conn, %{"slug" => slug}) do
    case Urls.get_short_url(slug) do
      {:ok, short_url} ->
        Urls.increment_visits(short_url)

        conn
        |> redirect(external: short_url.target)

      error ->
        # See `ShortenerWeb.FallbackController` for the `{:error, :not_found}` fallback
        error
    end
  end
end
