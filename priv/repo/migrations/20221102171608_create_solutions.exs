defmodule Quizy.Repo.Migrations.CreateSolutions do
  use Ecto.Migration

  def change do
    create table(:solutions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :score, :float
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :quiz_id, references(:quizes, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:solutions, [:user_id, :quiz_id])
    create index(:solutions, [:quiz_id])
  end
end
