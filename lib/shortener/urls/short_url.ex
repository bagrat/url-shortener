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
  def create_changeset(short_url, attrs) do
    short_url
    |> cast(attrs, [:slug, :target, :visits, :owner_id])
    |> maybe_initialize_visits()
    |> validate_required([:slug, :target, :visits])
    |> validate_target()
    |> unique_constraint(:slug, name: :short_urls_slug_index)
  end

  def update_changeset(short_url, attrs) do
    short_url
    |> cast(attrs, [:slug])
    |> validate_required([:slug])
    |> unique_constraint(:slug, name: :short_urls_slug_index)
  end

  @doc false
  def validate_slug(short_url, attrs) do
    short_url
    |> cast(attrs, [:slug])
    |> validate_required([:slug])
    |> unique_constraint(:slug, name: :short_urls_slug_index)
  end

  def maybe_initialize_visits(changeset) do
    if changeset.valid? and get_change(changeset, :visits) == nil do
      put_change(changeset, :visits, 0)
    else
      changeset
    end
  end

  @valid_url_regex ~r/^(https?:\/\/)([\p{L}\p{N}\p{S}\-\.]+)\.([\p{L}\p{N}]{2,})([\/\p{L}\p{N}\p{S}\/\.\-_]*)*\/*$/

  defp validate_target(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{target: target}} ->
        if Regex.match?(@valid_url_regex, target) do
          changeset
        else
          add_error(changeset, :target, "is not a valid URL")
        end

      _ ->
        changeset
    end
  end
end
