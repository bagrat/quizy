defmodule QuizyWeb.ErrorView do
  use QuizyWeb, :view

  def render("401.json", _assigns) do
    render_error("you must pass a bearer token in a header to authenticate")
  end

  def render("404.json", _assigns) do
    render_error("not found")
  end

  def render("error.json", %{error_message: message}) do
    render_error(message)
  end

  def render_error(error) do
    render_errors([error])
  end

  def render_errors(errors) do
    %{errors: errors}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
