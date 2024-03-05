defmodule ShortenerWeb.ShortUrlControllerTest do
  alias Shortener.Urls.ShortUrl
  use ShortenerWeb.ConnCase

  test "GET /:slug redirects to the target URL", %{conn: conn} do
    {:ok, short_url} = Shortener.Urls.create_short_url("https://bagrat.io")

    conn = get(conn, ~p"/#{short_url.slug}")

    assert redirected_to(conn) == short_url.target
  end

  test "GET /:slug increments the visits count", %{conn: conn} do
    {:ok, short_url} = Shortener.Urls.create_short_url("https://bagrat.io")

    conn = get(conn, ~p"/#{short_url.slug}")

    assert {:ok, %{visits: 1}} = Shortener.Urls.get_short_url(short_url.slug)

    conn = get(conn, ~p"/#{short_url.slug}")

    assert {:ok, %{visits: 2}} = Shortener.Urls.get_short_url(short_url.slug)
  end
end
