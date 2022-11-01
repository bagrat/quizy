defmodule QuizyWeb.QuizView do
  use QuizyWeb, :view
  alias QuizyWeb.QuizView

  def render("index.json", %{quizes: quizes}) do
    render_many(quizes, QuizView, "quiz.json")
  end

  def render("show.json", %{quiz: quiz}) do
    render_one(quiz, QuizView, "quiz.json")
  end

  def render("quiz.json", %{quiz: quiz}) do
    %{
      id: quiz.id,
      title: quiz.title,
      published: quiz.published?
    }
  end
end
