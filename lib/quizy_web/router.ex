defmodule QuizyWeb.Router do
  use QuizyWeb, :router

  import QuizyWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {QuizyWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", QuizyWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", QuizyWeb do
  #   pipe_through :api
  # end

  ## API routes
  scope "/api", QuizyWeb do
    pipe_through [:api]

    post "/users/tokens", API.TokenController, :create

    post "/users", API.UserController, :create
  end

  scope "/api", QuizyWeb do
    pipe_through [:api, :authenticate_bearer_token]

    get "/quizes/:id", QuizController, :show
    get "/quizes", QuizController, :index
    post "/quizes", QuizController, :create
    put "/quizes/:id", QuizController, :update
    delete "/quizes/:id", QuizController, :delete

    post "/quizes/:quiz_id/questions", QuestionController, :create
    put "/questions/:id", QuestionController, :update
    delete "/questions/:id", QuestionController, :delete

    post "/questions/:question_id/answers", AnswerController, :create
    put "/answers/:id", AnswerController, :update
    delete "/answers/:id", AnswerController, :delete

    post "/quizes/:quiz_id/solutions", SolutionController, :create
    get "/quizes/:quiz_id/solutions", SolutionController, :index_for_quiz
    get "/solutions", SolutionController, :index_for_user
  end

  ## Authentication routes
  scope "/", QuizyWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", QuizyWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", QuizyWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end
