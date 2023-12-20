defmodule Todewie.Todews do
  import Ecto.Query, warn: false

  alias Todewie.Repo
  alias Todewie.Todews.Todew


  def list_posts do
    query =
      from t in Todew,
      select: t,
      order_by: [desc: :inserted_at],
      preload: [:user]

    Repo.all(query)
  end

  def save(todew_params) do
    %Todew{}
    |> Todew.changeset(todew_params)
    |> Repo.insert()
  end
end
