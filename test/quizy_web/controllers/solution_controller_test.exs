defmodule QuizyWeb.SolutionControllerTest do
  use QuizyWeb.ConnCase

  import Quizy.QuizesFixtures
  import Quizy.AccountsFixtures

  alias Quizy.Quizes.Solution
  alias Quizy.Quizes.Question

  setup %{conn: conn} do
    fixtures = QuizyWeb.SetupHelpers.setup_auth(conn)

    {:ok, fixtures}
  end

  @tag wip: true
  test "creating a solution returns the scores", %{auth_conn: conn, user: user} do
    owner = user_fixture()
    quiz = quiz_for_user_fixture(owner)

    %Question{id: question1_id} = question1 = question_for_quiz_fixture(quiz)
    answer1_1 = answer_for_question_fixture(question1, %{"correct" => true})
    _answer1_2 = answer_for_question_fixture(question1, %{"correct" => false})

    %Question{id: question2_id} =
      question2 = question_for_quiz_fixture(quiz, %{"multiple_choice" => true})

    _answer2_1 = answer_for_question_fixture(question2, %{"correct" => true})
    answer2_2 = answer_for_question_fixture(question2, %{"correct" => true})
    answer2_3 = answer_for_question_fixture(question2, %{"correct" => true})
    _answer2_4 = answer_for_question_fixture(question2, %{"correct" => false})
    answer2_5 = answer_for_question_fixture(question2, %{"correct" => false})

    %Question{id: question3_id} =
      question3 = question_for_quiz_fixture(quiz, %{"multiple_choice" => true})

    _answer3_1 = answer_for_question_fixture(question3, %{"correct" => true})
    _answer3_2 = answer_for_question_fixture(question3, %{"correct" => true})
    _answer3_3 = answer_for_question_fixture(question3, %{"correct" => false})

    solution_params = %{
      "solution" => %{
        "question_solutions" => [
          %{"question_id" => question1_id, "picked_answers" => [answer1_1.id]},
          %{
            "question_id" => question2_id,
            "picked_answers" => [answer2_2.id, answer2_3.id, answer2_5.id]
          }
        ]
      }
    }

    conn = post(conn, Routes.solution_path(conn, :create, quiz.id), solution_params)
    assert %{"score" => score, "question_scores" => question_scores} = json_response(conn, 201)

    question2_score = 1 / 3 + 1 / 3 - 1 / 2

    assert [
             %{"question_id" => question1_id, "score" => 1},
             %{"question_id" => question2_id, "score" => question2_score},
             %{"question_id" => question3_id, "score" => 0}
           ] == question_scores

    assert score == 1 + question2_score
  end

  @tag wip: true
  test "creating a solution erros on bad input", %{auth_conn: conn, user: user} do
    owner = user_fixture()
    quiz = quiz_for_user_fixture(owner)

    question = question_for_quiz_fixture(quiz)
    answer1 = answer_for_question_fixture(question, %{"correct" => true})
    _answer2 = answer_for_question_fixture(question, %{"correct" => false})

    {:ok, does_not_exist} = Ecto.UUID.cast(Ecto.UUID.bingenerate())

    assert_error_sent 404, fn ->
      post(conn, Routes.solution_path(conn, :create, quiz.id), %{
        "solution" => %{
          "question_solutions" => [
            %{"question_id" => does_not_exist, "picked_answers" => [answer1.id]}
          ]
        }
      })
    end
  end

  @tag wip: true
  test "listing all solution for a quiz returns scores", %{auth_conn: conn, user: owner} do
    quiz = quiz_for_user_fixture(owner)

    %Question{id: question1_id} = question1 = question_for_quiz_fixture(quiz)
    answer1_1 = answer_for_question_fixture(question1, %{"correct" => true})
    _answer1_2 = answer_for_question_fixture(question1, %{"correct" => false})

    %Question{id: question2_id} =
      question2 = question_for_quiz_fixture(quiz, %{"multiple_choice" => true})

    _answer2_1 = answer_for_question_fixture(question2, %{"correct" => true})
    answer2_2 = answer_for_question_fixture(question2, %{"correct" => true})
    answer2_3 = answer_for_question_fixture(question2, %{"correct" => true})
    _answer2_4 = answer_for_question_fixture(question2, %{"correct" => false})
    answer2_5 = answer_for_question_fixture(question2, %{"correct" => false})

    %Question{id: question3_id} =
      question3 = question_for_quiz_fixture(quiz, %{"multiple_choice" => true})

    _answer3_1 = answer_for_question_fixture(question3, %{"correct" => true})
    _answer3_2 = answer_for_question_fixture(question3, %{"correct" => true})
    _answer3_3 = answer_for_question_fixture(question3, %{"correct" => false})

    solution_params = %{
      "solution" => %{
        "question_solutions" => [
          %{"question_id" => question1_id, "picked_answers" => [answer1_1.id]},
          %{
            "question_id" => question2_id,
            "picked_answers" => [answer2_2.id, answer2_3.id, answer2_5.id]
          }
        ]
      }
    }

    post(conn, Routes.solution_path(conn, :create, quiz.id), solution_params)
    conn = get(conn, Routes.solution_path(conn, :index_for_quiz, quiz.id))
    assert [%{"score" => score, "question_scores" => question_scores}] = json_response(conn, 200)
  end

  @tag wip: true
  test "listing all solution for a user returns scores", %{auth_conn: conn, user: user} do
    owner = user_fixture()
    quiz = quiz_for_user_fixture(owner)

    %Question{id: question1_id} = question1 = question_for_quiz_fixture(quiz)
    answer1_1 = answer_for_question_fixture(question1, %{"correct" => true})
    _answer1_2 = answer_for_question_fixture(question1, %{"correct" => false})

    %Question{id: question2_id} =
      question2 = question_for_quiz_fixture(quiz, %{"multiple_choice" => true})

    _answer2_1 = answer_for_question_fixture(question2, %{"correct" => true})
    answer2_2 = answer_for_question_fixture(question2, %{"correct" => true})
    answer2_3 = answer_for_question_fixture(question2, %{"correct" => true})
    _answer2_4 = answer_for_question_fixture(question2, %{"correct" => false})
    answer2_5 = answer_for_question_fixture(question2, %{"correct" => false})

    %Question{id: question3_id} =
      question3 = question_for_quiz_fixture(quiz, %{"multiple_choice" => true})

    _answer3_1 = answer_for_question_fixture(question3, %{"correct" => true})
    _answer3_2 = answer_for_question_fixture(question3, %{"correct" => true})
    _answer3_3 = answer_for_question_fixture(question3, %{"correct" => false})

    solution_params = %{
      "solution" => %{
        "question_solutions" => [
          %{"question_id" => question1_id, "picked_answers" => [answer1_1.id]},
          %{
            "question_id" => question2_id,
            "picked_answers" => [answer2_2.id, answer2_3.id, answer2_5.id]
          }
        ]
      }
    }

    post(conn, Routes.solution_path(conn, :create, quiz.id), solution_params)
    conn = get(conn, Routes.solution_path(conn, :index_for_user))
    assert [%{"score" => score, "question_scores" => question_scores}] = json_response(conn, 200)
  end
end
