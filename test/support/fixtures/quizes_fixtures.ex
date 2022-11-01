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
end
