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
  def changeset(short_url, attrs) do
    short_url
    |> cast(attrs, [:slug, :target, :visits])
    |> validate_required([:slug, :target, :visits])
  end

  @doc false
  def changeset_without_owner(short_url, attrs) do
    short_url
    |> cast(attrs, [:slug, :target])
    |> initialize_visits()
    |> validate_required([:slug, :target, :visits])
    |> validate_target()
    |> unique_constraint(:slug, name: :short_urls_slug_index)
  end

  def initialize_visits(short_url) do
    short_url
    |> put_change(:visits, 0)
  end

  @valid_url_regex ~r"^(https?://)?([\da-z\.-]+)\.([a-z\.]{2,6})([/\w \.-]*)*/?$"

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
