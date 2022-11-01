defmodule Quizy.QuizesTest do
  use Quizy.DataCase

  alias Quizy.Quizes

  describe "quizes" do
    alias Quizy.Quizes.Quiz

    import Quizy.QuizesFixtures
    import Quizy.AccountsFixtures

    @invalid_attrs %{"published" => nil, "title" => nil}

    test "list_quizes/0 returns all quizes" do
      user = user_fixture()

      quizes = for _quiz <- 1..3, do: quiz_for_user_fixture(user, %{})

      assert Quizes.list_quizes_for_user(user) == quizes
    end

    test "get_quiz!/1 returns the quiz with given id" do
      quiz = quiz_fixture()
      assert Quizes.get_quiz!(quiz.id) == quiz
    end

    test "create_quiz/1 with valid data creates a quiz" do
      user = user_fixture()
      valid_attrs = %{"published" => true, "title" => "some title"}

      assert {:ok, %Quiz{} = quiz} = Quizes.create_quiz(valid_attrs, user)
      assert quiz.published? == false
      assert quiz.user_id == user.id
      assert quiz.title == "some title"
    end

    test "create_quiz/1 with invalid data returns error changeset" do
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} = Quizes.create_quiz(@invalid_attrs, user)
    end

    test "update_quiz/2 with valid data updates the quiz" do
      quiz = quiz_fixture()
      update_attrs = %{"published" => true, "title" => "some updated title"}

      assert {:ok, %Quiz{} = quiz} = Quizes.update_quiz(quiz, update_attrs)
      assert quiz.published? == true
      assert quiz.title == "some updated title"
    end

    test "update_quiz/2 with invalid data returns error changeset" do
      quiz = quiz_fixture()
      assert {:error, %Ecto.Changeset{}} = Quizes.update_quiz(quiz, @invalid_attrs)
      assert quiz == Quizes.get_quiz!(quiz.id)
    end

    test "update_quiz/2 errors when the quiz is already published" do
      {:ok, quiz} =
        quiz_fixture()
        |> Quizes.update_quiz(%{published?: true})

      assert {:error, :already_published} = Quizes.update_quiz(quiz, %{})
    end

    test "delete_quiz/1 deletes the quiz" do
      quiz = quiz_fixture()
      assert {:ok, %Quiz{}} = Quizes.delete_quiz(quiz)
      assert_raise Ecto.NoResultsError, fn -> Quizes.get_quiz!(quiz.id) end
    end

    # test "change_quiz/1 returns a quiz changeset" do
    #   quiz = quiz_fixture()
    #   assert %Ecto.Changeset{} = Quizes.change_quiz(quiz)
    # end
  end
end
