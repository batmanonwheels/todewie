defmodule Todewie.Repo.Migrations.UsersAddNameImageColumns do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :name, :string
      add :image, :text
    end
  end
end
