defmodule Shortener.Urls.Test do
  alias Shortener.AccountsFixtures
  use Shortener.DataCase
  import Mock

  alias Shortener.Urls
  import AccountsFixtures

  test "create_short_url/1 creates a unique slug" do
    {:ok, short_url1} = Urls.create_short_url("https://bagrat.io")
    {:ok, short_url2} = Urls.create_short_url("https://bagrat.io")

    assert short_url1.slug != short_url2.slug
  end

  test "create_short_url/1 creates a short url" do
    {:ok, short_url} = Urls.create_short_url("https://bagrat.io")

    assert short_url.slug != ""
    assert short_url.target == "https://bagrat.io"
    assert short_url.visits == 0
    assert short_url.owner_id == nil
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

  test "create_short_url/1 creates a short url with an owner" do
    owner = user_fixture()

    {:ok, short_url} = Urls.create_short_url("https://bagrat.io", owner)

    assert short_url.owner_id == owner.id
  end

  test "list_user_urls/1 returns the list of URLs for the given user" do
    {:ok, _anonymous_url} = Urls.create_short_url("https://bagrat.io")

    owner = user_fixture()
    {:ok, short_url1} = Urls.create_short_url("https://google.com", owner)
    {:ok, short_url2} = Urls.create_short_url("https://deeporigin.com", owner)

    other_owner = user_fixture()
    {:ok, short_url3} = Urls.create_short_url("https://amazon.com", other_owner)

    assert Urls.list_user_urls(owner) == [short_url1, short_url2]
    assert Urls.list_user_urls(other_owner) == [short_url3]
  end
end
