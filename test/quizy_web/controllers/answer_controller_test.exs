defmodule QuizyWeb.AnswerControllerTest do
  use QuizyWeb.ConnCase

  import Quizy.QuizesFixtures
  import Quizy.AccountsFixtures

  alias Quizy.Quizes.Answer
  alias Quizy.Quizes

  @create_attrs %{
    "correct" => true,
    "text" => "some text"
  }
  @update_attrs %{
    "correct" => false,
    "text" => "some updated text"
  }
  @invalid_attrs %{"correct" => nil, "text" => nil}

  setup %{conn: conn} do
    fixtures = QuizyWeb.SetupHelpers.setup_auth(conn)

    {:ok, fixtures}
  end

  # describe "index" do
  #   test "lists all answers", %{auth_conn: conn} do
  #     conn = get(conn, Routes.answer_path(conn, :index))
  #     assert json_response(conn, 200)["data"] == []
  #   end
  # end

  describe "create answer" do
    test "renders answer when data is valid", %{auth_conn: conn, user: user} do
      quiz = quiz_for_user_fixture(user)
      question = question_for_quiz_fixture(quiz)

      conn = post(conn, Routes.answer_path(conn, :create, question.id), answer: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      assert %{
               id: ^id,
               correct?: true,
               text: "some text"
             } = Quizes.get_answer!(id)
    end

    test "may only be done by the quiz owner", %{auth_conn: conn} do
      other_user = user_fixture()
      quiz = quiz_for_user_fixture(other_user)
      question = question_for_quiz_fixture(quiz)

      conn = post(conn, Routes.answer_path(conn, :create, question.id), answer: @create_attrs)

      assert %{"errors" => ["not found"]} == json_response(conn, 404)
    end

    test "fails with 403 if there are already 5 answers existing", %{auth_conn: conn, user: user} do
      quiz = quiz_for_user_fixture(user)
      question = question_for_quiz_fixture(quiz)

      for _q <- 1..5,
          do: answer_for_question_fixture(question)

      conn = post(conn, Routes.answer_path(conn, :create, question.id), answer: @create_attrs)

      assert %{"errors" => ["up to 5 answers are allowed"]} == json_response(conn, 403)
    end

    test "is allowed only by the quiz owner", %{auth_conn: conn} do
      other_user = user_fixture()
      quiz = quiz_for_user_fixture(other_user)
      question = question_for_quiz_fixture(quiz)
      answer = answer_for_question_fixture(question)

      conn = put(conn, Routes.answer_path(conn, :update, answer), answer: @update_attrs)
      assert %{"errors" => ["not found"]} = json_response(conn, 404)
    end

    test "fails with 403 if the quiz is already published", %{
      auth_conn: conn,
      user: user
    } do
      quiz = quiz_for_user_fixture(user)
      question = question_for_quiz_fixture(quiz)
      answer = answer_for_question_fixture(question)

      Quizes.publish_quiz(quiz)

      conn = put(conn, Routes.answer_path(conn, :update, answer), answer: @update_attrs)
      assert %{"errors" => ["published quizes are not editable"]} = json_response(conn, 403)
    end

    @tag wip: true
    test "is able to change answer position", %{auth_conn: conn, user: user} do
      quiz = quiz_for_user_fixture(user)
      question = question_for_quiz_fixture(quiz)

      %Answer{id: id1} = answer1 = answer_for_question_fixture(question)
      %Answer{id: id2} = answer2 = answer_for_question_fixture(question)

      assert answer1.position == 0
      assert answer2.position == 1

      update_attrs = Map.put(@update_attrs, :position, 1)

      conn = put(conn, Routes.answer_path(conn, :update, id1), answer: update_attrs)
      assert %{"id" => ^id1} = json_response(conn, 200)

      assert %{
               id: ^id1,
               position: 1
             } = Quizes.get_answer!(id1)

      assert %{
               id: ^id2,
               position: 0
             } = Quizes.get_answer!(id2)
    end

    test "renders errors when data is invalid", %{auth_conn: conn, user: user} do
      quiz = quiz_for_user_fixture(user)
      question = question_for_quiz_fixture(quiz)

      conn = post(conn, Routes.answer_path(conn, :create, question.id), answer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update answer" do
    test "renders answer when data is valid", %{auth_conn: conn, user: user} do
      quiz = quiz_for_user_fixture(user)
      question = question_for_quiz_fixture(quiz)
      %Answer{id: id} = answer = answer_for_question_fixture(question)

      conn = put(conn, Routes.answer_path(conn, :update, answer), answer: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)

      assert %{
               id: ^id,
               correct?: false,
               text: "some updated text"
             } = Quizes.get_answer!(id)
    end

    test "renders errors when data is invalid", %{auth_conn: conn, user: user} do
      quiz = quiz_for_user_fixture(user)
      question = question_for_quiz_fixture(quiz)
      answer = answer_for_question_fixture(question)

      conn = put(conn, Routes.answer_path(conn, :update, answer), answer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete answer" do
    test "deletes chosen answer", %{auth_conn: conn, user: user} do
      quiz = quiz_for_user_fixture(user)
      question = question_for_quiz_fixture(quiz)
      answer = answer_for_question_fixture(question)

      conn = delete(conn, Routes.answer_path(conn, :delete, answer))
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        Quizes.get_answer!(answer.id)
      end
    end
  end
end
