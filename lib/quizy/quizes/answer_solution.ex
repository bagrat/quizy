defmodule Quizy.Quizes.AnswerSolution do
  use Ecto.Schema
  import Ecto.Changeset

  alias Quizy.Quizes.Solution
  alias Quizy.Quizes.Question
  alias Quizy.Quizes.Answer

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "answer_solutions" do
    field :score, :float

    belongs_to :solution, Solution
    belongs_to :question, Question
    belongs_to :answer, Answer

    timestamps()
  end

  @doc false
  def create_changeset(solution, attrs) do
    solution
    |> cast(attrs, [:solution_id, :question_id, :answer_id, :score])
    |> validate_required([:solution_id, :question_id, :answer_id, :score])
  end
end
