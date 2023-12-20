defmodule Todewie.Repo.Migrations.CreateTodews do
  use Ecto.Migration

  def change do
    create table(:todews) do
      add :text, :string
      add :image, :string
      add :completed, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:todews, [:user_id])
  end
end
