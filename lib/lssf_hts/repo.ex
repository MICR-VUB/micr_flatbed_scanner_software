defmodule LssfHts.Repo do
  use Ecto.Repo,
    otp_app: :lssf_hts,
    adapter: Ecto.Adapters.Postgres
end
