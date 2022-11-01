defmodule Quizy.Quizes.Quiz do
  use Ecto.Schema
  import Ecto.Changeset

  alias Quizy.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quizes" do
    field :published?, :boolean, default: false, source: :published
    field :title, :string

    belongs_to :user, Quizy.Accounts.User
    has_many :questions, Quizy.Quizes.Question

    timestamps()
  end

  @doc false
  def create_changeset(quiz, attrs) do
    quiz
    |> cast(attrs, [:user_id, :title])
    |> validate_required([:user_id, :title])
  end

  @doc false
  def update_changeset(quiz, attrs) do
    attrs = Repo.rename_bool_attrs(attrs, ["published"])

    quiz
    |> cast(attrs, [:title, :published?])
    |> validate_required([:title, :published?])
  end
end
