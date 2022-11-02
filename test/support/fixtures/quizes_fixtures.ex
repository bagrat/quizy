defmodule Quizy.QuizesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Quizy.Quizes` context.
  """

  alias Quizy.AccountsFixtures

  @doc """
  Generate a quiz.
  """
  def quiz_fixture(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture()

    {:ok, quiz} =
      attrs
      |> Enum.into(%{
        "published" => false,
        "title" => "some title"
      })
      |> Quizy.Quizes.create_quiz(user)

    quiz
  end

  @doc """
  Generate a quiz for the specified user.
  """
  def quiz_for_user_fixture(user, attrs \\ %{}) do
    {:ok, quiz} =
      attrs
      |> Enum.into(%{
        "published" => false,
        "title" => "some title"
      })
      |> Quizy.Quizes.create_quiz(user)

    quiz
  end

  @doc """
  Generate a question for a specified quiz.
  """
  def question_for_quiz_fixture(quiz, attrs \\ %{}) do
    {:ok, question} =
      attrs
      |> Enum.into(%{
        "multiple_choice" => false,
        "text" => "some text"
      })
      |> Quizy.Quizes.create_question(quiz)

    question
  end

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    quiz = quiz_fixture()

    {:ok, question} =
      attrs
      |> Enum.into(%{
        "multiple_choice" => false,
        "text" => "some text"
      })
      |> Quizy.Quizes.create_question(quiz)

    question
  end

  @doc """
  Generate a answer for question.
  """
  def answer_for_question_fixture(question, attrs \\ %{}) do
    {:ok, answer} =
      attrs
      |> Enum.into(%{
        "correct" => false,
        "text" => "some text"
      })
      |> Quizy.Quizes.create_answer(question)

    answer
  end

  @doc """
  Generate a answer.
  """
  def answer_fixture(attrs \\ %{}) do
    question = question_fixture()

    {:ok, answer} =
      attrs
      |> Enum.into(%{
        "correct" => false,
        "text" => "some text"
      })
      |> Quizy.Quizes.create_answer(question)

    answer
  end

  @doc """
  Generate a solution.
  """
  def solution_fixture(quiz, user, attrs \\ %{}) do
    solution =
      attrs
      |> Enum.into(%{})
      |> Quizy.Quizes.create_solution!(quiz, user)

    solution
  end
end
