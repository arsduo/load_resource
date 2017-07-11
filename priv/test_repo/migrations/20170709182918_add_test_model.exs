defmodule TestRepo.Migrations.AddTestModel do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string
      add :user_id, :int
      add :publisher, :string
    end
  end
end
