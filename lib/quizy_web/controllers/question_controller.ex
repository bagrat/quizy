defmodule QuizyWeb.QuestionController do
  use QuizyWeb, :controller

  alias Quizy.Quizes
  alias Quizy.Quizes.Question

  action_fallback QuizyWeb.FallbackController

  #   def index(conn, _params) do
  #     questions = Quizes.list_questions()
  #     render(conn, "index.json", questions: questions)
  #   end

  def create(conn, %{"question" => question_params, "quiz_id" => quiz_id}) do
    with quiz <- Quizes.get_quiz!(quiz_id),
         {:owner?, true} <- {:owner?, conn.assigns.current_user.id == quiz.user_id},
         {:ok, %Question{} = question} <-
           Quizes.create_question(question_params, quiz) do
      conn
      |> put_status(:created)
      |> render("show.json", question: question)
    else
      {:owner?, false} ->
        conn
        |> put_status(:not_found)
        |> put_view(QuizyWeb.ErrorView)
        |> render("404.json")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(QuizyWeb.ChangesetView)
        |> put_status(422)
        |> render("error.json", changeset: changeset)
    end
  end

  # def show(conn, %{"id" => id}) do
  #   question = Quizes.get_question!(id)
  #   render(conn, "show.json", question: question)
  # end

  def update(conn, %{"id" => id, "question" => question_params}) do
    with question <- Quizes.get_question!(id),
         quiz <- Quizes.get_quiz!(question.quiz_id),
         {:owner?, true} <- {:owner?, quiz.id == conn.assigns.current_user.id},
         {:ok, %Question{} = question} <- Quizes.update_question(question, question_params) do
      render(conn, "show.json", question: question)
    else
      {:owner?, false} ->
        conn
        |> put_status(:not_found)
        |> put_view(QuizyWeb.ErrorView)
        |> render("404.json")

      {:error, :already_published} ->
        conn
        |> put_view(QuizyWeb.ErrorView)
        |> put_status(403)
        |> render("error.json", error_message: "published quizes are not editable")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(QuizyWeb.ChangesetView)
        |> put_status(422)
        |> render("error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    question = Quizes.get_question!(id)

    with {:ok, %Question{}} <- Quizes.delete_question(question) do
      send_resp(conn, :no_content, "")
    end
  end
end
