defmodule Quizy.QuizesTest do
  use Quizy.DataCase

  alias Quizy.Quizes

  alias Quizy.Quizes.Quiz

  import Quizy.QuizesFixtures
  import Quizy.AccountsFixtures

  describe "quizes" do
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

    test "quiz_available?/2 returns true if the requesting user is the owner" do
      owner = user_fixture()
      quiz = quiz_for_user_fixture(owner)

      assert quiz.published? == false
      assert Quizes.quiz_available?(quiz, owner) == true
    end

    test "quiz_available?/2 returns true if the requesting user is not the owner but the quiz is published" do
      owner = user_fixture()
      quiz = quiz_for_user_fixture(owner)

      {:ok, quiz} = Quizes.publish_quiz(quiz)

      assert quiz.published? == true

      user = user_fixture()

      assert Quizes.quiz_available?(quiz, user) == true
    end

    test "quiz_available?/2 returns false if the requesting user is not the owner and the quiz is not published" do
      owner = user_fixture()
      quiz = quiz_for_user_fixture(owner)

      user = user_fixture()

      assert Quizes.quiz_available?(quiz, user) == false
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
  end

  describe "questions" do
    alias Quizy.Quizes.Question

    import Quizy.QuizesFixtures

    @invalid_attrs %{"multiple_choice" => nil, "text" => nil}

    test "list_questions/0 returns all questions ordered by position" do
      quiz1 = quiz_fixture()
      quiz2 = quiz_fixture()

      questions1 = for _q <- 1..5, do: question_for_quiz_fixture(quiz1)
      questions2 = for _q <- 1..5, do: question_for_quiz_fixture(quiz2)

      assert Quizes.list_questions(quiz1) == questions1
      assert Quizes.list_questions(quiz2) == questions2

      assert Quizes.list_questions(quiz1)
             |> Enum.map(fn %{position: position} -> position end) == [0, 1, 2, 3, 4]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Quizes.get_question!(question.id) == question
    end

    test "create_question/2 adds a question to the quiz at the last position" do
      valid_attrs = %{"multiple_choice" => false, "text" => "some text"}
      quiz = quiz_fixture()

      assert {:ok, %Question{} = question} = Quizes.create_question(valid_attrs, quiz)
      assert question.multiple_choice? == false
      assert question.text == "some text"
      assert question.position == 0
      assert question.quiz_id == quiz.id

      assert {:ok, %Question{} = question} = Quizes.create_question(valid_attrs, quiz)
      assert question.multiple_choice? == false
      assert question.text == "some text"
      assert question.position == 1
      assert question.quiz_id == quiz.id

      assert {:ok, %Question{} = question} = Quizes.create_question(valid_attrs, quiz)
      assert question.multiple_choice? == false
      assert question.text == "some text"
      assert question.position == 2
      assert question.quiz_id == quiz.id
    end

    test "create_question/2 fails if the quiz is already published" do
      quiz = quiz_fixture()

      {:ok, quiz} = Quizes.publish_quiz(quiz)

      assert {:error, :already_published} == Quizes.create_question(%{}, quiz)
    end

    test "create_question/1 with invalid data returns error changeset" do
      quiz = quiz_fixture()
      assert {:error, %Ecto.Changeset{}} = Quizes.create_question(@invalid_attrs, quiz)
    end

    test "of up to 10 may be added to a quiz" do
      valid_attrs = %{"multiple_choice" => false, "text" => "some text"}
      quiz = quiz_fixture()

      for _q <- 1..10, do: question_for_quiz_fixture(quiz)

      assert {:error, :too_many_questions} = Quizes.create_question(valid_attrs, quiz)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      update_attrs = %{"multiple_choice" => true, "text" => "some updated text"}

      assert {:ok, %Question{} = question} = Quizes.update_question(question, update_attrs)
      assert question.multiple_choice? == true
      assert question.text == "some updated text"
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Quizes.update_question(question, @invalid_attrs)
      assert question == Quizes.get_question!(question.id)
    end

    test "update_question/2 reorders other questions if the position is changed" do
      # Shifting down
      quiz = quiz_fixture()
      [_q0, q1, q2, q3, _q4] = for _q <- 1..5, do: question_for_quiz_fixture(quiz)

      assert {:ok, question} = Quizes.update_question(q3, %{"position" => 1})
      assert question.position == 1

      question_1_id = q1.id

      assert %Question{id: ^question_1_id, position: 2} = Quizes.get_question!(question_1_id)

      question_2_id = q2.id

      assert %Question{id: ^question_2_id, position: 3} = Quizes.get_question!(question_2_id)

      # Shifting up
      quiz = quiz_fixture()
      [q0, q1, q2, q3, q4] = for _q <- 1..5, do: question_for_quiz_fixture(quiz)

      assert {:ok, question} = Quizes.update_question(q0, %{"position" => 4})
      assert question.position == 4

      question_1_id = q1.id

      assert %Question{id: ^question_1_id, position: 0} = Quizes.get_question!(question_1_id)

      question_2_id = q2.id

      assert %Question{id: ^question_2_id, position: 1} = Quizes.get_question!(question_2_id)

      question_3_id = q3.id

      assert %Question{id: ^question_3_id, position: 2} = Quizes.get_question!(question_3_id)

      question_4_id = q4.id

      assert %Question{id: ^question_4_id, position: 3} = Quizes.get_question!(question_4_id)
    end

    test "update_question/2 fails if the quiz is already published" do
      quiz = quiz_fixture()
      question = question_for_quiz_fixture(quiz)

      Quizes.publish_quiz(quiz)

      assert {:error, :already_published} == Quizes.update_question(question, %{})
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = Quizes.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Quizes.get_question!(question.id) end
    end

    test "delete_question/1 deletes the question and reorders the rest" do
      quiz = quiz_fixture()
      [q0, q1, q2, q3, q4] = for _q <- 1..5, do: question_for_quiz_fixture(quiz)

      assert {:ok, %Question{}} = Quizes.delete_question(q1)

      question_0_id = q0.id

      assert %Question{id: ^question_0_id, position: 0} = Quizes.get_question!(question_0_id)

      question_2_id = q2.id

      assert %Question{id: ^question_2_id, position: 1} = Quizes.get_question!(question_2_id)

      question_3_id = q3.id

      assert %Question{id: ^question_3_id, position: 2} = Quizes.get_question!(question_3_id)

      question_4_id = q4.id

      assert %Question{id: ^question_4_id, position: 3} = Quizes.get_question!(question_4_id)
    end
  end

  describe "answers" do
    alias Quizy.Quizes.Answer

    import Quizy.QuizesFixtures

    @invalid_attrs %{"correct" => nil, "text" => nil}

    test "list_answers/1 returns all answers for question ordered by position" do
      question1 = question_fixture()
      question2 = question_fixture()
      answers1 = for _a <- 1..3, do: answer_for_question_fixture(question1)
      answers2 = for _a <- 1..3, do: answer_for_question_fixture(question2)

      assert Quizes.list_answers(question1) == answers1
      assert Quizes.list_answers(question2) == answers2

      assert Quizes.list_answers(question1)
             |> Enum.map(fn %{position: position} -> position end) == [0, 1, 2]
    end

    test "get_answer!/1 returns the answer with given id" do
      answer = answer_fixture()
      assert Quizes.get_answer!(answer.id) == answer
    end

    test "create_answer/2 with valid data creates a answer" do
      valid_attrs = %{"correct" => true, "text" => "some text"}

      question = question_fixture()

      assert {:ok, %Answer{} = answer} = Quizes.create_answer(valid_attrs, question)
      assert answer.correct? == true
      assert answer.text == "some text"
      assert answer.position == 0

      assert {:ok, %Answer{} = answer} = Quizes.create_answer(valid_attrs, question)
      assert answer.correct? == true
      assert answer.text == "some text"
      assert answer.position == 1
    end

    test "create_answer/2 fails if the quiz is already published" do
      quiz = quiz_fixture()
      question = question_for_quiz_fixture(quiz)

      Quizes.publish_quiz(quiz)

      valid_attrs = %{"correct" => true, "text" => "some text"}

      assert {:error, :already_published} == Quizes.create_answer(valid_attrs, question)
    end

    test "create_answer/1 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Quizes.create_answer(@invalid_attrs, question)
    end

    test "update_answer/2 with valid data updates the answer" do
      answer = answer_fixture()
      update_attrs = %{"correct" => false, "text" => "some updated text"}

      assert {:ok, %Answer{} = answer} = Quizes.update_answer(answer, update_attrs)
      assert answer.correct? == false
      assert answer.text == "some updated text"
    end

    test "update_answer/2 is allowed only for unpublished quizes" do
      quiz = quiz_fixture()
      question = question_for_quiz_fixture(quiz)
      answer = answer_for_question_fixture(question)

      Quizes.publish_quiz(quiz)

      assert {:error, :already_published} == Quizes.update_answer(answer, %{})
    end

    test "update_answer/2 reorders other answers if the position is changed" do
      # Shifting down
      question = question_fixture()
      [_q0, a1, a2, a3, _a4] = for _q <- 1..5, do: answer_for_question_fixture(question)

      assert {:ok, answer} = Quizes.update_answer(a3, %{"position" => 1})
      assert answer.position == 1

      answer_1_id = a1.id

      assert %Answer{id: ^answer_1_id, position: 2} = Quizes.get_answer!(answer_1_id)

      answer_2_id = a2.id

      assert %Answer{id: ^answer_2_id, position: 3} = Quizes.get_answer!(answer_2_id)

      # Shifting up
      question = question_fixture()
      [q0, a1, a2, a3, a4] = for _q <- 1..5, do: answer_for_question_fixture(question)

      assert {:ok, answer} = Quizes.update_answer(q0, %{"position" => 4})
      assert answer.position == 4

      answer_1_id = a1.id

      assert %Answer{id: ^answer_1_id, position: 0} = Quizes.get_answer!(answer_1_id)

      answer_2_id = a2.id

      assert %Answer{id: ^answer_2_id, position: 1} = Quizes.get_answer!(answer_2_id)

      answer_3_id = a3.id

      assert %Answer{id: ^answer_3_id, position: 2} = Quizes.get_answer!(answer_3_id)

      answer_4_id = a4.id

      assert %Answer{id: ^answer_4_id, position: 3} = Quizes.get_answer!(answer_4_id)
    end

    test "update_answer/2 with invalid data returns error changeset" do
      answer = answer_fixture()
      assert {:error, %Ecto.Changeset{}} = Quizes.update_answer(answer, @invalid_attrs)
      assert answer == Quizes.get_answer!(answer.id)
    end

    test "delete_answer/1 deletes the answer" do
      answer = answer_fixture()
      assert {:ok, %Answer{}} = Quizes.delete_answer(answer)
      assert_raise Ecto.NoResultsError, fn -> Quizes.get_answer!(answer.id) end
    end
  end
end
