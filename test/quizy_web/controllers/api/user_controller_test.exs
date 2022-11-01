defmodule QuizyWeb.UserControllerTest do
  use QuizyWeb.ConnCase

  import Quizy.AccountsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "makes a new user given the email and password", %{conn: conn} do
      email = "some@email.com"
      password = "hmmmmmmmmmmmm!"

      conn =
        post(conn, Routes.user_path(conn, :create),
          user: %{"email" => email, "password" => password}
        )

      assert conn.status == 201
    end

    test "fails with 400 if the password is shorter than 12 chars", %{conn: conn} do
      email = "some@email.com"
      password = "12345"

      conn =
        post(conn, Routes.user_path(conn, :create),
          user: %{"email" => email, "password" => password}
        )

      assert %{"errors" => %{"password" => ["should be at least 12 character(s)"]}} ==
               json_response(conn, 400)
    end

    test "fails when there already exists a user with the same email", %{conn: conn} do
      password = "nothing matters"
      user = user_fixture(%{"password" => password})

      conn =
        post(conn, Routes.user_path(conn, :create),
          user: %{"email" => user.email, "password" => password}
        )

      assert %{"errors" => %{"email" => ["has already been taken"]}} == json_response(conn, 400)
    end
  end
end
