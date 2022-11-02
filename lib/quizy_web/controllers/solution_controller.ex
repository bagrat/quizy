defmodule QuizyWeb.SolutionController do
  use QuizyWeb, :controller

  alias Quizy.Quizes
  alias Quizy.Quizes.Solution

  action_fallback QuizyWeb.FallbackController

  def index_for_quiz(conn, %{"quiz_id" => quiz_id} = params) do
    quiz = Quizes.get_quiz!(quiz_id)

    case quiz.user_id == conn.assigns.current_user.id do
      true ->
        solutions = Quizes.list_solutions_for_quiz(quiz.id)
        render(conn, "index.json", solutions: solutions)

      false ->
        conn
        |> put_status(:not_found)
        |> put_view(QuizyWeb.ErrorView)
        |> render("404.json")
    end
  end

  def index_for_user(%{assigns: %{current_user: user}} = conn, _params) do
    solutions = Quizes.list_solutions_for_user(user.id)
    render(conn, "index.json", solutions: solutions)
  end

  def create(conn, %{"quiz_id" => quiz_id, "solution" => solution_params}) do
    with quiz <- Quizes.get_quiz!(quiz_id),
         user <- conn.assigns.current_user,
         solution <- Quizes.create_solution!(solution_params, quiz, user) do
      conn
      |> put_status(:created)
      |> render("show.json", solution: solution)
    end
  end
end
