defmodule QuizyWeb.QuizController do
  use QuizyWeb, :controller

  alias Quizy.Quizes
  alias Quizy.Quizes.Quiz

  action_fallback QuizyWeb.FallbackController

  def index(conn, _params) do
    quizes = Quizes.list_quizes_for_user(conn.assigns.current_user)
    render(conn, "index.json", quizes: quizes)
  end

  def create(conn, %{"quiz" => quiz_params}) do
    with user <- conn.assigns.current_user,
         {:ok, %Quiz{} = quiz} <- Quizes.create_quiz(quiz_params, user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.quiz_path(conn, :show, quiz.id))
      |> render("show.json", quiz: quiz)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> Phoenix.Controller.put_view(QuizyWeb.ChangesetView)
        |> put_status(422)
        |> render("error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    quiz = Quizes.get_quiz!(id)
    current_user = conn.assigns.current_user

    case Quizes.quiz_available?(quiz, current_user) do
      true ->
        render(conn, "show.json", quiz: quiz)

      false ->
        conn
        |> put_view(QuizyWeb.ErrorView)
        |> put_status(404)
        |> render("error.json", error_message: "not found")
    end
  end

  def update(conn, %{"id" => id, "quiz" => quiz_params}) do
    quiz = Quizes.get_quiz!(id)

    with {:ok, %Quiz{} = quiz} <- Quizes.update_quiz(quiz, quiz_params) do
      render(conn, "show.json", quiz: quiz)
    else
      {:error, :already_published} ->
        conn
        |> put_view(QuizyWeb.ErrorView)
        |> put_status(403)
        |> render("error.json", error_message: "published quizes are not editable")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> Phoenix.Controller.put_view(QuizyWeb.ChangesetView)
        |> put_status(422)
        |> render("error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    quiz = Quizes.get_quiz!(id)

    with {:ok, %Quiz{}} <- Quizes.delete_quiz(quiz) do
      send_resp(conn, :no_content, "")
    end
  end
end
