defmodule Shortener.Repo.Migrations.CreateShortUrls do
  use Ecto.Migration

  def change do
    create table(:short_urls) do
      add :slug, :string
      add :target, :string
      add :visits, :integer
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:short_urls, [:slug], unique: true)
    create index(:short_urls, [:owner_id])
  end
end
