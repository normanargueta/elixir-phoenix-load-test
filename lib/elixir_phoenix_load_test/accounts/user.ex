defmodule ElixirPhoenixLoadTest.Accounts.User do
  use Ecto.Schema

  schema "users" do
    field :email, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end
end
