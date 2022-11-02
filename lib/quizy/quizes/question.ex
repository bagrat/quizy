defmodule Quizy.Quizes.Question do
  use Ecto.Schema
  import Ecto.Changeset

  alias Quizy.Repo
  alias Quizy.Quizes.Answer

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "questions" do
    field :text, :string
    field :position, :integer
    field :multiple_choice?, :boolean, default: false, source: :multiple_choice

    belongs_to :quiz, Quizy.Quizes.Quiz
    has_many :answers, Answer

    timestamps()
  end

  @doc false
  def create_changeset(question, attrs) do
    attrs = Repo.rename_bool_attrs(attrs, ["multiple_choice"])

    question
    |> cast(attrs, [:quiz_id, :text, :position, :multiple_choice?])
    |> validate_required([:quiz_id, :text, :position, :multiple_choice?])
  end

  @doc false
  def update_changeset(question, attrs) do
    attrs = Repo.rename_bool_attrs(attrs, ["multiple_choice"])

    question
    |> cast(attrs, [:text, :position, :multiple_choice?])
    |> validate_required([:text, :position, :multiple_choice?])
  end
end
