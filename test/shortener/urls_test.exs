defmodule Shortener.Urls.Test do
  use Shortener.DataCase
  import Mock

  alias Shortener.Urls

  test "create_short_url/1 creates a short url" do
    {:ok, short_url} = Urls.create_short_url("https://bagrat.io")

    assert short_url.slug != ""
    assert short_url.target == "https://bagrat.io"
    assert short_url.visits == 0
    assert short_url.owner_id == nil
  end

  test "create_short_url/1 creates a unique slug" do
    {:ok, short_url1} = Urls.create_short_url("https://bagrat.io")
    {:ok, short_url2} = Urls.create_short_url("https://bagrat.io")

    assert short_url1.slug != short_url2.slug
  end

  test "create_short_url/1 regenerates the slug if one already exists" do
    with_mock Shortener.SlugGenerator,
      random_slug: [in_series([], ["same_slug", "same_slug", "other_slug"])] do
      {:ok, short_url} = Shortener.Urls.create_short_url("https://bagrat.io")
      assert short_url.slug == "same_slug"

      {:ok, short_url} = Shortener.Urls.create_short_url("https://bagrat.io")
      assert short_url.slug == "other_slug"
    end
  end
end
