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
  Returns a quiz as if it was requested by the specified user.

  If the user is not the owner of the quiz, it is returned only if published.
  """
  def quiz_available?(quiz, user) when quiz.user_id == user.id, do: true
  def quiz_available?(quiz, user) when quiz.published?, do: true
  def quiz_available?(quiz, user), do: false

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
  Publishes the quiz.
  """
  def publish_quiz(%Quiz{published?: false} = quiz) do
    update_quiz(quiz, %{"published" => "true"})
  end

  def publish_quiz(%Quiz{published?: true}), do: {:error, :already_published}

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

  alias Quizy.Quizes.Question

  @doc """
  Returns the list of questions.

  ## Examples

      iex> list_questions()
      [%Question{}, ...]

  """
  def list_questions(quiz) do
    query =
      from q in Question,
        where: q.quiz_id == ^quiz.id,
        order_by: q.position

    Repo.all(query)
  end

  @doc """
  Gets a single question.

  Raises `Ecto.NoResultsError` if the Question does not exist.

  ## Examples

      iex> get_question!(123)
      %Question{}

      iex> get_question!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question!(id), do: Repo.get!(Question, id)

  @doc """
  Creates a question.

  ## Examples

      iex> create_question(%{field: value})
      {:ok, %Question{}}

      iex> create_question(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question(attrs, quiz) do
    num_of_questions = get_number_of_questions(quiz)

    attrs =
      attrs
      |> Map.merge(%{"quiz_id" => quiz.id})

    create_question_at_position(attrs, quiz, num_of_questions)
  end

  defp create_question_at_position(attrs, quiz, position) when position in 0..9 do
    attrs =
      attrs
      |> Map.merge(%{"position" => position})

    %Question{}
    |> Question.create_changeset(attrs)
    |> Repo.insert()
  end

  defp create_question_at_position(attrs, quiz, position), do: {:error, :too_many_questions}

  defp get_number_of_questions(quiz) do
    query = from q in Question, where: q.quiz_id == ^quiz.id, select: count()
    Repo.one(query)
  end

  @doc """
  Updates a question.

  ## Examples

      iex> update_question(question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_question(question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question(%Question{} = question, %{"position" => new_position} = attrs)
      when new_position != question.position do
    quiz = get_quiz!(question.quiz_id)
    num_of_questions = get_number_of_questions(quiz)

    case new_position < num_of_questions do
      true ->
        validated_question =
          question
          |> Question.update_changeset(attrs)

        query =
          case new_position > question.position do
            true ->
              query =
                from q in Question,
                  where:
                    q.quiz_id == ^quiz.id and q.position > ^question.position and
                      q.position <= ^new_position,
                  update: [set: [position: q.position - 1]]

            false ->
              query =
                from q in Question,
                  where:
                    q.quiz_id == ^quiz.id and q.position < ^question.position and
                      q.position >= ^new_position,
                  update: [set: [position: q.position + 1]]
          end

        {:ok, %{update_position: question}} =
          Ecto.Multi.new()
          |> Ecto.Multi.put(:query, query)
          |> Ecto.Multi.update_all(:shift, query, [])
          |> Ecto.Multi.update(:update_position, validated_question)
          |> Repo.transaction()

        {:ok, question}

      false ->
        {:error, :bad_position}
    end
  end

  def update_question(%Question{} = question, attrs) do
    question
    |> Question.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a question.

  ## Examples

      iex> delete_question(question)
      {:ok, %Question{}}

      iex> delete_question(question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Question{} = question) do
    query =
      from q in Question,
        where: q.quiz_id == ^question.quiz_id and q.position > ^question.position,
        update: [set: [position: q.position - 1]]

    {:ok, %{delete: result}} =
      Ecto.Multi.new()
      |> Ecto.Multi.delete(:delete, question)
      |> Ecto.Multi.update_all(:shift, query, [])
      |> Repo.transaction()

    {:ok, result}
  end
end
