defmodule Quizy.Quizes.Quiz do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quizes" do
    field :published?, :boolean, default: false, source: :published
    field :title, :string
    belongs_to :user, Quizy.Accounts.User

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
    attrs = rename_published(attrs)

    quiz
    |> cast(attrs, [:title, :published?])
    |> validate_required([:title, :published?])
  end

  defp rename_published(%{"published" => published} = attrs) do
    attrs
    |> Map.put("published?", published)
    |> Map.drop(["published"])
  end

  defp rename_published(attrs), do: attrs
end
