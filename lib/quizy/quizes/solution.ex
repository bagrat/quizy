defmodule Quizy.Quizes.Solution do
  use Ecto.Schema
  import Ecto.Changeset

  alias Quizy.Quizes.AnswerSolution
  alias Quizy.Quizes.Quiz
  alias Quizy.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "solutions" do
    field :score, :float
    field :question_scores, {:array, :map}, virtual: true

    belongs_to :user, User
    belongs_to :quiz, Quiz
    has_many :answer_solutions, AnswerSolution

    timestamps()
  end

  @doc false
  def create_changeset(solution, attrs) do
    solution
    |> cast(attrs, [:user_id, :quiz_id])
    |> validate_required([:user_id, :quiz_id])
  end

  @doc false
  def update_changeset(solution, attrs) do
    solution
    |> cast(attrs, [:score])
    |> validate_required([:score])
  end
end
