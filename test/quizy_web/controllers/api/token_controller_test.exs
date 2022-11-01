defmodule QuizyWeb.TokenControllerTest do
  use QuizyWeb.ConnCase

  import Quizy.AccountsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create token" do
    test "returns token when credentials are valid", %{conn: conn} do
      password = "nothing matters"
      user = user_fixture(%{"password" => password})

      conn =
        post(conn, Routes.token_path(conn, :create),
          user: %{"email" => user.email, "password" => password}
        )

      assert token = json_response(conn, 200)

      assert {:ok, token_raw} = Phoenix.Token.verify(QuizyWeb.Endpoint, "bearer token", token)
      assert token_raw == user.id
    end

    test "renders error when credentials are invalid", %{conn: conn} do
      conn =
        post(conn, Routes.token_path(conn, :create),
          user: %{email: "bad email", password: "bad password"}
        )

      assert [auth_error] = json_response(conn, 400)["errors"]
      assert auth_error == "Invalid email or password"
    end
  end
end
