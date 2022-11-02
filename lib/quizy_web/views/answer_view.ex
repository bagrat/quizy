defmodule QuizyWeb.AnswerView do
  use QuizyWeb, :view
  alias QuizyWeb.AnswerView

  def render("index.json", %{answers: answers}) do
    render_many(answers, AnswerView, "answer.json")
  end

  def render("show.json", %{answer: answer}) do
    render_one(answer, AnswerView, "answer.json")
  end

  def render("answer.json", %{answer: answer}) do
    %{
      id: answer.id,
      text: answer.text,
      correct: answer.correct?
    }
  end
end
