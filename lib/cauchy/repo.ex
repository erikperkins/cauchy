defmodule Cauchy.Repo do
  use Ecto.Repo,
    otp_app: :cauchy,
    adapter: Ecto.Adapters.Postgres
end
