defmodule QuizyWeb.API.UserController do
  use QuizyWeb, :controller

  alias Quizy.Accounts

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        conn
        |> send_resp(201, "")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> Phoenix.Controller.put_view(QuizyWeb.ChangesetView)
        |> put_status(400)
        |> render("error.json", changeset: changeset)
    end
  end
end
