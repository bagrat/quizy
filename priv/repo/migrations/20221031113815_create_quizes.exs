defmodule Quizy.Repo.Migrations.CreateQuizes do
  use Ecto.Migration

  def change do
    create table(:quizes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :published, :boolean, default: false, null: false

      add :user_id, references(:users, type: :uuid)

      timestamps()
    end

    create index(:quizes, [:user_id])
  end
end
