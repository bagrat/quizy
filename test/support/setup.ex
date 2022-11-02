defmodule QuizyWeb.SetupHelpers do
  import Quizy.AccountsFixtures
  import Quizy.TokenFixtures

  def setup_auth(conn) do
    user = user_fixture()
    token = token_fixture(user)

    conn = Plug.Conn.put_req_header(conn, "accept", "application/json")

    auth_conn =
      conn
      |> put_auth_header(token)

    %{conn: conn, auth_conn: auth_conn, user: user}
  end
end
