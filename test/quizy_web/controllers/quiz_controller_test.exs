defmodule QuizyWeb.QuizControllerTest do
  use QuizyWeb.ConnCase

  import Quizy.QuizesFixtures
  import Quizy.AccountsFixtures

  alias Quizy.Quizes

  @create_attrs %{
    published?: false,
    title: "some title"
  }
  @update_attrs %{
    published?: true,
    title: "some updated title"
  }
  @invalid_attrs %{published?: nil, title: nil}

  setup %{conn: conn} do
    fixtures = QuizyWeb.SetupHelpers.setup_auth(conn)

    {:ok, fixtures}
  end

  describe "index" do
    test "lists all quizes of the logged in user", %{auth_conn: conn, user: user} do
      _other_quizes = for _quiz <- 1..3, do: quiz_fixture()

      quizes =
        for(
          _quiz <- 1..3,
          do: quiz_for_user_fixture(user)
        )
        |> Enum.map(fn %{id: id, title: title, published?: published?} ->
          %{"id" => id, "title" => title, "published" => published?}
        end)

      conn = get(conn, Routes.quiz_path(conn, :index))
      assert json_response(conn, 200) == quizes
    end
  end

  test "only published quizes are available to other users", %{auth_conn: conn} do
    others_quiz = quiz_fixture()
    question = question_for_quiz_fixture(others_quiz)
    answer_for_question_fixture(question, %{"correct" => true})

    conn = get(conn, Routes.quiz_path(conn, :show, others_quiz.id))
    assert conn.status == 404

    Quizes.publish_quiz(others_quiz)

    conn = get(conn, Routes.quiz_path(conn, :show, others_quiz.id))

    assert %{
             "id" => others_quiz.id,
             "published" => true,
             "title" => others_quiz.title
           } == json_response(conn, 200)
  end

  test "attempting to publish an incomplete quiz fails with 403", %{auth_conn: conn, user: user} do
    quiz = quiz_for_user_fixture(user)

    assert quiz.published? == false

    conn = put(conn, Routes.quiz_path(conn, :update, quiz), quiz: %{"published" => true})

    quiz = Quizes.get_quiz!(quiz.id)
    assert quiz.published? == false

    assert %{
             "errors" => ["cannot publish an incomplete quiz"]
           } == json_response(conn, 403)
  end

  test "unpublished quizes are available to the owners", %{auth_conn: conn, user: user} do
    quiz = quiz_for_user_fixture(user)

    assert quiz.published? == false

    conn = get(conn, Routes.quiz_path(conn, :show, quiz.id))

    assert %{
             "id" => quiz.id,
             "published" => false,
             "title" => quiz.title
           } == json_response(conn, 200)
  end

  describe "create quiz" do
    test "returns the ID", %{auth_conn: conn} do
      conn = post(conn, Routes.quiz_path(conn, :create), quiz: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.quiz_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "published" => false,
               "title" => "some title"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{auth_conn: conn} do
      conn = post(conn, Routes.quiz_path(conn, :create), quiz: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update quiz" do
    test "is allowed when it is unpublished", %{auth_conn: conn, user: user} do
      quiz = quiz_for_user_fixture(user)

      conn = put(conn, Routes.quiz_path(conn, :update, quiz), quiz: @update_attrs)
      conn = get(conn, Routes.quiz_path(conn, :show, quiz.id))

      quiz_id = quiz.id

      assert %{
               "id" => ^quiz_id,
               "published" => true,
               "title" => "some updated title"
             } = json_response(conn, 200)
    end

    test "is allowed only by the owner", %{auth_conn: conn} do
      other_user = user_fixture()
      quiz = quiz_for_user_fixture(other_user)

      conn = put(conn, Routes.quiz_path(conn, :update, quiz), quiz: @update_attrs)

      assert %{
               "errors" => ["not found"]
             } = json_response(conn, 404)
    end

    test "is not allowed when already published", %{auth_conn: conn, user: user} do
      quiz = quiz_for_user_fixture(user)

      conn = put(conn, Routes.quiz_path(conn, :update, quiz), quiz: @update_attrs)

      assert conn.status == 200

      conn = put(conn, Routes.quiz_path(conn, :update, quiz), quiz: @update_attrs)

      assert %{
               "errors" => ["published quizes are not editable"]
             } = json_response(conn, 403)
    end

    test "renders errors when data is invalid", %{auth_conn: conn, user: user} do
      quiz = quiz_for_user_fixture(user)

      conn = put(conn, Routes.quiz_path(conn, :update, quiz), quiz: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete quiz" do
    test "deletes chosen quiz", %{auth_conn: conn, user: user} do
      quiz = quiz_for_user_fixture(user)

      conn = delete(conn, Routes.quiz_path(conn, :delete, quiz))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.quiz_path(conn, :show, quiz))
      end
    end
  end
end
