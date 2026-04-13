defmodule ElixirPhoenixLoadTest.Repo do
  use Ecto.Repo,
    otp_app: :elixir_phoenix_load_test,
    adapter: Ecto.Adapters.Postgres
end
