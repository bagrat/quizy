defmodule QuizyWeb.AnswerController do
  use QuizyWeb, :controller

  alias Quizy.Quizes
  alias Quizy.Quizes.Quiz
  alias Quizy.Quizes.Question
  alias Quizy.Quizes.Answer
  alias Quizy.Repo

  action_fallback QuizyWeb.FallbackController

  # def index(conn, _params) do
  #   answers = Quizes.list_answers()
  #   render(conn, "index.json", answers: answers)
  # end

  def create(conn, %{"question_id" => question_id, "answer" => answer_params}) do
    with question <- Quizes.get_question!(question_id),
         %Question{quiz: %Quiz{user: owner}} <- Repo.preload(question, quiz: [:user]),
         {:owner?, true} <- {:owner?, owner == conn.assigns.current_user},
         {:ok, %Answer{} = answer} <-
           Quizes.create_answer(answer_params, question) do
      conn
      |> put_status(:created)
      |> render("show.json", answer: answer)
    else
      {:owner?, false} ->
        conn
        |> put_status(:not_found)
        |> put_view(QuizyWeb.ErrorView)
        |> render("404.json")

      {:error, :too_many_answers} ->
        conn
        |> put_status(:forbidden)
        |> put_view(QuizyWeb.ErrorView)
        |> render("error.json", error_message: "up to 5 answers are allowed")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(QuizyWeb.ChangesetView)
        |> put_status(422)
        |> render("error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    answer = Quizes.get_answer!(id)
    render(conn, "show.json", answer: answer)
  end

  def update(conn, %{"id" => id, "answer" => answer_params}) do
    with answer <- Quizes.get_answer!(id),
         %Answer{question: %Question{quiz: %Quiz{user: owner}}} <-
           Repo.preload(answer, question: [quiz: [:user]]),
         {:owner?, true} <- {:owner?, owner == conn.assigns.current_user},
         {:ok, %Answer{} = answer} <- Quizes.update_answer(answer, answer_params) do
      render(conn, "show.json", answer: answer)
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
    answer = Quizes.get_answer!(id)

    with {:ok, %Answer{}} <- Quizes.delete_answer(answer) do
      send_resp(conn, :no_content, "")
    end
  end
end
