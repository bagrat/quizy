defmodule Quizy.Quizes do
  @moduledoc """
  The Quizes context.
  """

  import Ecto.Query, warn: false
  alias Quizy.Repo

  alias Quizy.Quizes.Quiz
  alias Quizy.Quizes.Question
  alias Quizy.Quizes.Answer

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
  def quiz_available?(quiz, _user) when quiz.published?, do: true
  def quiz_available?(_quiz, _user), do: false

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

  def update_quiz(%Quiz{published?: false} = quiz, %{"published" => true} = attrs) do
    case quiz_complete?(quiz) do
      true ->
        quiz
        |> Quiz.update_changeset(attrs)
        |> Repo.update()

      false ->
        {:error, :incomplete}
    end
  end

  def update_quiz(%Quiz{} = quiz, attrs) do
    quiz
    |> Quiz.update_changeset(attrs)
    |> Repo.update()
  end

  defp quiz_complete?(%Quiz{questions: []}), do: false

  defp quiz_complete?(%Quiz{questions: questions}) when is_list(questions) do
    questions
    |> Enum.map(fn question ->
      question
      |> Repo.preload(:answers)
      |> question_complete?()
    end)
    |> Enum.all?()
  end

  defp quiz_complete?(quiz) do
    quiz
    |> Repo.preload(:questions)
    |> quiz_complete?()
  end

  defp question_complete?(%Question{answers: []}), do: false

  defp question_complete?(%Question{answers: answers, multiple_choice?: true} = _questions)
       when is_list(answers) do
    answers
    |> Enum.map(fn answer -> answer.correct? end)
    |> Enum.any?()
  end

  defp question_complete?(%Question{answers: answers, multiple_choice?: false} = _questions)
       when is_list(answers) do
    1 ==
      answers
      |> Enum.map(fn answer -> answer.correct? end)
      |> Enum.filter(& &1)
      |> length()
  end

  @doc """
  Publishes the quiz.
  """
  def publish_quiz(%Quiz{published?: false} = quiz) do
    update_quiz(quiz, %{"published" => true})
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
  def create_question(_attrs, %Quiz{published?: true}) do
    {:error, :already_published}
  end

  def create_question(attrs, quiz) do
    num_of_questions = get_number_of_questions(quiz)

    attrs =
      attrs
      |> Map.merge(%{"quiz_id" => quiz.id})

    create_question_at_position(attrs, num_of_questions)
  end

  defp create_question_at_position(attrs, position) when position in 0..9 do
    attrs =
      attrs
      |> Map.merge(%{"position" => position})

    %Question{}
    |> Question.create_changeset(attrs)
    |> Repo.insert()
  end

  defp create_question_at_position(_attrs, _position), do: {:error, :too_many_questions}

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
  def update_question(%Question{quiz: %Ecto.Association.NotLoaded{}} = question, attrs) do
    question
    |> Repo.preload(:quiz)
    |> update_question(attrs)
  end

  def update_question(%Question{quiz: %Quiz{published?: true}}, _attrs),
    do: {:error, :already_published}

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
              from q in Question,
                where:
                  q.quiz_id == ^quiz.id and q.position > ^question.position and
                    q.position <= ^new_position,
                update: [set: [position: q.position - 1]]

            false ->
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

  alias Quizy.Quizes.Answer

  @doc """
  Returns the list of answers.

  ## Examples

      iex> list_answers()
      [%Answer{}, ...]

  """
  def list_answers(question) do
    query = from a in Answer, where: a.question_id == ^question.id, order_by: [:position]

    Repo.all(query)
  end

  @doc """
  Gets a single answer.

  Raises `Ecto.NoResultsError` if the Answer does not exist.

  ## Examples

      iex> get_answer!(123)
      %Answer{}

      iex> get_answer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_answer!(id), do: Repo.get!(Answer, id)

  @doc """
  Creates a answer.

  ## Examples

      iex> create_answer(%{field: value})
      {:ok, %Answer{}}

      iex> create_answer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_answer(attrs, %Question{quiz: %Ecto.Association.NotLoaded{}} = question) do
    create_answer(attrs, Repo.preload(question, :quiz))
  end

  def create_answer(_attrs, %Question{quiz: %Quiz{published?: true}}) do
    {:error, :already_published}
  end

  def create_answer(attrs, question) do
    num_of_questions = get_number_of_answers(question)

    attrs =
      attrs
      |> Map.merge(%{"question_id" => question.id})

    create_answer_at_position(attrs, num_of_questions)
  end

  defp create_answer_at_position(attrs, position) when position in 0..4 do
    attrs =
      attrs
      |> Map.merge(%{"position" => position})

    %Answer{}
    |> Answer.create_changeset(attrs)
    |> Repo.insert()
  end

  defp create_answer_at_position(_attrs, _position), do: {:error, :too_many_answers}

  defp get_number_of_answers(question) do
    query = from a in Answer, where: a.question_id == ^question.id, select: count()
    Repo.one(query)
  end

  @doc """
  Updates a answer.

  ## Examples

      iex> update_answer(answer, %{field: new_value})
      {:ok, %Answer{}}

      iex> update_answer(answer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_answer(%Answer{question: %Ecto.Association.NotLoaded{}} = answer, attrs) do
    answer
    |> Repo.preload(question: [:quiz])
    |> update_answer(attrs)
  end

  def update_answer(%Answer{question: %Question{quiz: %Quiz{published?: true}}}, _attrs) do
    {:error, :already_published}
  end

  def update_answer(%Answer{} = answer, %{"position" => new_position} = attrs)
      when new_position != answer.position do
    question = get_question!(answer.question_id)
    num_of_answers = get_number_of_answers(question)

    case new_position < num_of_answers do
      true ->
        validated_answer =
          answer
          |> Answer.update_changeset(attrs)

        query =
          case new_position > answer.position do
            true ->
              from q in Answer,
                where:
                  q.question_id == ^question.id and q.position > ^answer.position and
                    q.position <= ^new_position,
                update: [set: [position: q.position - 1]]

            false ->
              from q in Answer,
                where:
                  q.question_id == ^question.id and q.position < ^answer.position and
                    q.position >= ^new_position,
                update: [set: [position: q.position + 1]]
          end

        {:ok, %{update_position: answer}} =
          Ecto.Multi.new()
          |> Ecto.Multi.put(:query, query)
          |> Ecto.Multi.update_all(:shift, query, [])
          |> Ecto.Multi.update(:update_position, validated_answer)
          |> Repo.transaction()

        {:ok, answer}

      false ->
        {:error, :bad_position}
    end
  end

  def update_answer(%Answer{} = answer, attrs) do
    answer
    |> Answer.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a answer.

  ## Examples

      iex> delete_answer(answer)
      {:ok, %Answer{}}

      iex> delete_answer(answer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_answer(%Answer{} = answer) do
    query =
      from a in Answer,
        where: a.question_id == ^answer.question_id and a.position > ^answer.position,
        update: [set: [position: a.position - 1]]

    {:ok, %{delete: result}} =
      Ecto.Multi.new()
      |> Ecto.Multi.delete(:delete, answer)
      |> Ecto.Multi.update_all(:shift, query, [])
      |> Repo.transaction()

    {:ok, result}
  end

  alias Quizy.Quizes.Solution

  def list_solutions_for_quiz(quiz_id) do
    query = from s in Solution, where: s.quiz_id == ^quiz_id

    query
    |> Repo.all()
    |> Enum.map(fn solution ->
      populate_scores(solution)
    end)
  end

  def list_solutions_for_user(user_id) do
    query = from s in Solution, where: s.user_id == ^user_id

    query
    |> Repo.all()
    |> Enum.map(fn solution ->
      populate_scores(solution)
    end)
  end

  @doc """
  Creates a solution.

  ## Examples

      iex> create_solution(%{field: value})
      {:ok, %Solution{}}

      iex> create_solution(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_solution!(%{"question_solutions" => question_solutions} = attrs, quiz, user) do
    attrs =
      attrs
      |> Map.put("quiz_id", quiz.id)
      |> Map.put("user_id", user.id)

    solution =
      %Solution{}
      |> Solution.create_changeset(attrs)
      |> Repo.insert!()

    question_solutions
    |> Enum.map(fn %{"question_id" => question_id, "picked_answers" => picked_answers} ->
      question =
        get_question!(question_id)
        |> Repo.preload(:answers)

      {correct_weight, incorrect_weight} = get_answer_weights(question)

      question.answers
      |> Enum.filter(fn %Answer{id: id} ->
        id in picked_answers
      end)
      |> Enum.map(fn
        %Answer{id: id, correct?: true} -> {id, correct_weight}
        %Answer{id: id, correct?: false} -> {id, incorrect_weight}
      end)
      |> Enum.each(fn {id, weight} ->
        create_answer_solution!(
          %{
            "answer_id" => id,
            "score" => weight
          },
          solution,
          question
        )
      end)
    end)

    solution =
      solution
      |> populate_scores()

    score =
      solution.question_scores
      |> Enum.reduce(0, fn %{score: score}, total -> total + score end)

    solution
    |> Solution.update_changeset(%{score: score})
    |> Repo.update!()
  end

  def populate_scores(solution) do
    question_scores = get_question_scores(solution)

    solution
    |> Map.put(:question_scores, question_scores)
  end

  alias Quizy.Quizes.AnswerSolution

  defp get_question_scores(solution) do
    answer_query =
      from answer_solution in AnswerSolution, where: answer_solution.solution_id == ^solution.id

    answer_solutions = Repo.all(answer_query)

    questions =
      Question
      |> where([q], q.quiz_id == ^solution.quiz_id)
      |> order_by([q], q.position)
      |> Repo.all()

    question_scores =
      answer_solutions
      |> Enum.reduce(%{}, fn %AnswerSolution{question_id: id, score: score}, scores ->
        {_old, scores} =
          scores
          |> Map.get_and_update(id, fn
            nil -> {nil, score}
            score_so_far -> {score_so_far, score_so_far + score}
          end)

        scores
      end)

    questions
    |> Enum.map(fn %Question{id: id} ->
      %{question_id: id, score: Map.get(question_scores, id, 0)}
    end)
  end

  defp get_answer_weights(question) do
    %Question{answers: answers} = question

    num_of_correct =
      answers
      |> Enum.map(fn answer -> answer.correct? end)
      |> Enum.filter(& &1)
      |> length

    num_of_incorrect = length(answers) - num_of_correct

    correct_weight = 1 / num_of_correct
    incorrect_weight = -1 / num_of_incorrect

    {correct_weight, incorrect_weight}
  end

  defp create_answer_solution!(attrs, solution, question) do
    attrs =
      attrs
      |> Map.put("solution_id", solution.id)
      |> Map.put("question_id", question.id)

    %AnswerSolution{}
    |> AnswerSolution.create_changeset(attrs)
    |> Repo.insert!()
  end
end
