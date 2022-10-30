defmodule QuizyWeb.ErrorView do
  use QuizyWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  def render("401.json", _assigns) do
    render_error("you must pass a bearer token in a header to authenticate")
  end

  def render("400.json", %{error_message: message}) do
    render_error(message)
  end

  def render("400.json", %{changeset: changeset}) do
    render_errors(translate_errors(changeset))
  end

  def render_error(error) do
    render_errors([error])
  end

  def render_errors(errors) do
    %{errors: errors}
  end

  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
