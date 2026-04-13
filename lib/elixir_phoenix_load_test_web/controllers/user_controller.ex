defmodule ElixirPhoenixLoadTestWeb.UserController do
  use ElixirPhoenixLoadTestWeb, :controller

  alias ElixirPhoenixLoadTest.Repo
  alias ElixirPhoenixLoadTest.Accounts.User
  import Ecto.Query

  def index(conn, params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    per_page = Map.get(params, "per_page", "20") |> String.to_integer()
    offset = (page - 1) * per_page

    users =
      from(u in User, order_by: u.id, limit: ^per_page, offset: ^offset)
      |> Repo.all()

    json(conn, %{
      page: page,
      per_page: per_page,
      data: Enum.map(users, &%{id: &1.id, email: &1.email, name: &1.name})
    })
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(User, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      user ->
        json(conn, %{id: user.id, email: user.email, name: user.name})
    end
  end
end
