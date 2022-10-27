defmodule QuizyWeb.PageController do
  use QuizyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
