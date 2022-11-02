defmodule Quizy.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :string, null: false
      add :multiple_choice, :boolean, default: false, null: false
      add :position, :integer, null: false

      add :quiz_id, references(:quizes, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:questions, [:quiz_id, :position])
  end
end
