defmodule QuizyWeb.QuestionView do
  use QuizyWeb, :view
  alias QuizyWeb.QuestionView

  def render("index.json", %{questions: questions}) do
    render_many(questions, QuestionView, "question.json")
  end

  def render("show.json", %{question: question}) do
    render_one(question, QuestionView, "question.json")
  end

  def render("question.json", %{question: question}) do
    %{
      id: question.id,
      text: question.text,
      multiple_choice: question.multiple_choice?
    }
  end
end
