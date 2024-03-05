defmodule ShortenerWeb.ShortUrlController do
  use ShortenerWeb, :controller

  action_fallback ShortenerWeb.FallbackController

  def go_to_target(conn, %{"slug" => slug}) do
    case Shortener.Urls.get_target_url(slug) do
      {:ok, target} ->
        conn
        |> redirect(external: target)

      error ->
        # See `ShortenerWeb.FallbackController` for the `{:error, :not_found}` fallback
        error
    end
  end
end
