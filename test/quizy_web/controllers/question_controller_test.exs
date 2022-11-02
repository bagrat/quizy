defmodule QuizyWeb.QuestionControllerTest do
  use QuizyWeb.ConnCase

  import Quizy.QuizesFixtures
  import Quizy.AccountsFixtures

  alias Quizy.Quizes.Question
  alias Quizy.Quizes

  @create_attrs %{
    multiple_choice: true,
    text: "some text"
  }
  @update_attrs %{
    multiple_choice: false,
    text: "some updated text"
  }
  @invalid_attrs %{multiple_choice: nil, text: nil}

  setup %{conn: conn} do
    fixtures = QuizyWeb.SetupHelpers.setup_auth(conn)

    {:ok, fixtures}
  end

  # describe "index" do
  #   test "lists all questions", %{conn: conn} do
  #     conn = get(conn, Routes.question_path(conn, :index))
  #     assert json_response(conn, 200)["data"] == []
  #   end
  # end

  describe "creating question" do
    @describetag wip: true

    test "returns the new ID", %{auth_conn: conn, user: user} do
      quiz = quiz_for_user_fixture(user)
      conn = post(conn, Routes.question_path(conn, :create, quiz.id), question: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      assert %{
               id: ^id,
               multiple_choice?: true,
               text: "some text"
             } = Quizes.get_question!(id)
    end

    test "may only be done my the quiz owner", %{auth_conn: conn} do
      other_user = user_fixture()
      quiz = quiz_for_user_fixture(other_user)

      conn = post(conn, Routes.question_path(conn, :create, quiz.id), question: @create_attrs)

      assert %{"errors" => ["not found"]} == json_response(conn, 404)
    end

    test "returns 404 when no such quiz is found", %{auth_conn: conn} do
      {:ok, does_not_exist} = Ecto.UUID.cast(Ecto.UUID.bingenerate())

      assert_error_sent 404, fn ->
        post(conn, Routes.question_path(conn, :create, does_not_exist), question: @create_attrs)
      end
    end

    test "renders errors when data is invalid", %{auth_conn: conn, user: user} do
      quiz = quiz_for_user_fixture(user)
      conn = post(conn, Routes.question_path(conn, :create, quiz.id), question: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update question" do
    test "renders question when data is valid", %{
      auth_conn: conn
    } do
      %Question{id: id} = question = question_fixture()
      conn = put(conn, Routes.question_path(conn, :update, question), question: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)

      assert %{
               id: ^id,
               multiple_choice?: false,
               text: "some updated text"
             } = Quizes.get_question!(id)
    end

    @tag wip: true
    test "is able to change question position", %{auth_conn: conn} do
      quiz = quiz_fixture()
      %Question{id: id1} = question1 = question_for_quiz_fixture(quiz)
      %Question{id: id2} = question2 = question_for_quiz_fixture(quiz)

      assert question1.position == 0
      assert question2.position == 1

      update_attrs = Map.put(@update_attrs, :position, 1)

      conn = put(conn, Routes.question_path(conn, :update, id1), question: update_attrs)
      assert %{"id" => ^id1} = json_response(conn, 200)

      assert %{
               id: ^id1,
               multiple_choice?: false,
               text: "some updated text",
               position: 1
             } = Quizes.get_question!(id1)

      assert %{
               id: ^id2,
               position: 0
             } = Quizes.get_question!(id2)
    end

    test "renders errors when data is invalid", %{auth_conn: conn} do
      %Question{id: id} = question_fixture()
      conn = put(conn, Routes.question_path(conn, :update, id), question: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete question" do
    test "deletes chosen question", %{auth_conn: conn} do
      %Question{id: id} = question = question_fixture()
      conn = delete(conn, Routes.question_path(conn, :delete, question))
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        Quizes.get_question!(id)
      end
    end
  end
end
