defmodule QuizyWeb.SolutionView do
  use QuizyWeb, :view
  alias QuizyWeb.SolutionView

  def render("index.json", %{solutions: solutions}) do
    render_many(solutions, SolutionView, "solution.json")
  end

  def render("show.json", %{solution: solution}) do
    render_one(solution, SolutionView, "solution.json")
  end

  def render("solution.json", %{solution: solution}) do
    %{
      id: solution.id,
      score: solution.score,
      question_scores: solution.question_scores
    }
  end
end
