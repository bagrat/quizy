defmodule Quizy.Quizes.Question do
  use Ecto.Schema
  import Ecto.Changeset

  alias Quizy.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "questions" do
    field :multiple_choice?, :boolean, default: false, source: :multiple_choice
    field :text, :string

    belongs_to :quize, Quizy.Quizes.Quiz

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    attrs = Repo.rename_bool_attrs(attrs, ["multiple_choice"])

    question
    |> cast(attrs, [:text, :multiple_choice?])
    |> validate_required([:text, :multiple_choice?])
  end
end
