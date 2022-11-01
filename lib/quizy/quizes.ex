defmodule Quizy.Quizes do
  @moduledoc """
  The Quizes context.
  """

  import Ecto.Query, warn: false
  alias Quizy.Repo

  alias Quizy.Quizes.Quiz

  @doc """
  Returns the list of quizes.

  ## Examples

      iex> list_quizes()
      [%Quiz{}, ...]

  """
  def list_quizes_for_user(user) do
    query =
      from q in Quiz,
        where: q.user_id == ^user.id

    Repo.all(query)
  end

  @doc """
  Gets a single quiz.

  Raises `Ecto.NoResultsError` if the Quiz does not exist.

  ## Examples

      iex> get_quiz!(123)
      %Quiz{}

      iex> get_quiz!(456)
      ** (Ecto.NoResultsError)

  """
  def get_quiz!(id), do: Repo.get!(Quiz, id)

  @doc """
  Creates a quiz.

  ## Examples

      iex> create_quiz(%{field: value})
      {:ok, %Quiz{}}

      iex> create_quiz(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_quiz(attrs, user) do
    attrs =
      attrs
      |> Map.merge(%{"user_id" => user.id})

    %Quiz{}
    |> Quiz.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a quiz.

  ## Examples

      iex> update_quiz(quiz, %{field: new_value})
      {:ok, %Quiz{}}

      iex> update_quiz(quiz, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_quiz(%Quiz{published?: true}, _attrs) do
    {:error, :already_published}
  end

  def update_quiz(%Quiz{} = quiz, attrs) do
    quiz
    |> Quiz.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a quiz.

  ## Examples

      iex> delete_quiz(quiz)
      {:ok, %Quiz{}}

      iex> delete_quiz(quiz)
      {:error, %Ecto.Changeset{}}

  """
  def delete_quiz(%Quiz{} = quiz) do
    Repo.delete(quiz)
  end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking quiz changes.

  # ## Examples

  #     iex> change_quiz(quiz)
  #     %Ecto.Changeset{data: %Quiz{}}

  # """
  # def change_quiz(%Quiz{} = quiz, attrs \\ %{}) do
  #   Quiz.changeset(quiz, attrs)
  # end
end
