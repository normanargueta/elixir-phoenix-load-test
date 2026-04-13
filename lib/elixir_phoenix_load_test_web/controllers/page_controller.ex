defmodule ElixirPhoenixLoadTestWeb.PageController do
  use ElixirPhoenixLoadTestWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
