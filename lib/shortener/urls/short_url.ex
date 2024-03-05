defmodule Shortener.Urls.ShortUrl do
  use Ecto.Schema
  import Ecto.Changeset

  schema "short_urls" do
    field :target, :string
    field :slug, :string
    field :visits, :integer

    belongs_to :owner, Shortener.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset_without_owner(short_url, attrs) do
    short_url
    |> cast(attrs, [:slug, :target])
    |> initialize_visits()
    |> validate_required([:slug, :target, :visits])
    |> unique_constraint(:slug, name: :short_urls_slug_index)
  end

  def initialize_visits(short_url) do
    short_url
    |> put_change(:visits, 0)
  end
end
