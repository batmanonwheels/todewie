defmodule Todewie.Todews.Todew do
  use Ecto.Schema
  import Ecto.Changeset

  alias Todewie.Accounts.User

  schema "todews" do
    field :text, :string
    field :image, :string
    field :completed, :boolean, default: false
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todew, attrs) do
    todew
    |> cast(attrs, [:text, :image, :completed, :user_id])
    |> validate_required([:text, :user_id])
  end
end
