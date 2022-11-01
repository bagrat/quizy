defmodule Quizy.TokenFixtures do
  @moduledoc """
  This module defines test helpers for creating a bearer token.
  """

  alias Quizy.AccountsFixtures

  def token_fixture() do
    AccountsFixtures.user_fixture()
    |> token_fixture()
  end

  def token_fixture(user) do
    QuizyWeb.UserAuth.generate_user_bearer_token(user)
  end

  def put_auth_header(conn, token) do
    Plug.Conn.put_req_header(conn, "authorization", "Bearer #{token}")
  end
end
