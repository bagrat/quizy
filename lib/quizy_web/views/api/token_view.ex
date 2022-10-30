defmodule QuizyWeb.API.TokenView do
  use QuizyWeb, :view

  def render("show.json", %{token: token}) do
    token
  end
end
