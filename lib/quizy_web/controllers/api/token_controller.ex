defmodule QuizyWeb.API.TokenController do
  use QuizyWeb, :controller

  alias Quizy.Accounts
  alias QuizyWeb.UserAuth

  action_fallback QuizyWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      token = UserAuth.generate_user_bearer_token(user)

      render(conn, "show.json", token: token)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_view(QuizyWeb.ErrorView)
      |> put_status(:bad_request)
      |> render("400.json", error_message: "Invalid email or password")
    end
  end

  # def create(conn, %{"token" => token_params}) do
  #   with {:ok, %Token{} = token} <- Accounts.create_token(token_params) do
  #     conn
  #     |> put_status(:created)
  #     |> render("show.json", token: token)
  #   else
  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       conn
  #       |> put_view(QuzyWeb.ChangesetView)
  #       |> render("error.json", changeset: changeset)
  #   end
  # end
end
