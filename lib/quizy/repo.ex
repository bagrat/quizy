defmodule Quizy.Repo do
  use Ecto.Repo,
    otp_app: :quizy,
    adapter: Ecto.Adapters.Postgres
end
