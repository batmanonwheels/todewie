defmodule Todewie.Repo do
  use Ecto.Repo,
    otp_app: :todewie,
    adapter: Ecto.Adapters.Postgres
end
