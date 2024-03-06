defmodule ShortenerWeb.ShortUrlControllerTest do
  alias Shortener.Urls
  use ShortenerWeb.ConnCase

  test "GET /:slug redirects to the target URL", %{conn: conn} do
    {:ok, short_url} = Urls.create_short_url("https://bagrat.io")

    conn = get(conn, ~p"/#{short_url.slug}")

    assert redirected_to(conn) == short_url.target
  end

  test "GET /:slug increments the visits count", %{conn: conn} do
    {:ok, short_url} = Urls.create_short_url("https://bagrat.io")

    get(conn, ~p"/#{short_url.slug}")
    assert {:ok, %{visits: 1}} = Urls.get_short_url(short_url.slug)

    get(conn, ~p"/#{short_url.slug}")
    assert {:ok, %{visits: 2}} = Urls.get_short_url(short_url.slug)
  end
end
