defmodule Quizy.Repo.Migrations.CreateAnswers do
  use Ecto.Migration

  def change do
    create table(:answers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :string, null: false
      add :correct, :boolean, default: false, null: false
      add :position, :integer, null: false

      add :question_id, references(:questions, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:answers, [:question_id])
  end
end
