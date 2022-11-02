defmodule Quizy.Quizes.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Quizy.Quizes.Question
  alias Quizy.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "answers" do
    field :correct?, :boolean, default: false, source: :correct
    field :text, :string
    field :position, :integer

    belongs_to :question, Question

    timestamps()
  end

  @doc false
  def create_changeset(answer, attrs) do
    attrs = Repo.rename_bool_attrs(attrs, ["correct"])

    answer
    |> cast(attrs, [:question_id, :text, :correct?, :position])
    |> validate_required([:question_id, :text, :correct?, :position])
  end

  @doc false
  def update_changeset(answer, attrs) do
    attrs = Repo.rename_bool_attrs(attrs, ["correct"])

    answer
    |> cast(attrs, [:text, :correct?, :position])
    |> validate_required([:text, :correct?, :position])
  end
end
