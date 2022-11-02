defmodule Quizy.Repo.Migrations.CreateAnswerSolutions do
  use Ecto.Migration

  def change do
    create table(:answer_solutions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :score, :float

      add :solution_id, references(:solutions, on_delete: :nothing, type: :binary_id)
      add :question_id, references(:questions, on_delete: :nothing, type: :binary_id)
      add :answer_id, references(:answers, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:answer_solutions, [:solution_id])
  end
end
