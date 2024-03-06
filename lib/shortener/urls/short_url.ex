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

  @valid_url_regex ~r/^(https?:\/\/)([\p{L}\p{N}\p{S}\-\.]+)\.([\p{L}\p{N}]{2,})\/([\/\p{L}\p{N}\p{S}\/\.\-_]*)(\?[=&;\p{L}\p{N}\p{S}\-\_\.%]*)?\/?$/
  @valid_slug_regex ~r/^[a-zA-Z0-9_-]+$/

  @doc false
  def create_changeset(short_url, attrs) do
    short_url
    |> cast(attrs, [:slug, :target, :visits, :owner_id])
    |> maybe_initialize_visits()
    |> validate_required([:slug, :target, :visits])
    |> validate_format(:target, @valid_url_regex)
    |> validate_slug()
    |> unique_constraint(:slug, name: :short_urls_slug_index)
  end

  def update_changeset(short_url, attrs) do
    short_url
    |> cast(attrs, [:slug])
    |> validate_required([:slug])
    |> validate_slug()
    |> unique_constraint(:slug, name: :short_urls_slug_index)
  end

  def validate_slug(changeset) do
    changeset
    |> validate_length(:slug, min: 3, max: 20)
    |> validate_format(:slug, @valid_slug_regex)
  end

  def maybe_initialize_visits(changeset) do
    if changeset.valid? and get_change(changeset, :visits) == nil do
      put_change(changeset, :visits, 0)
    else
      changeset
    end
  end
end
