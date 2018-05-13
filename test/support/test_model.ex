defmodule LoadResource.TestModel do
  use Ecto.Schema

  schema "books" do
    field :title, :string
    field :user_id, :integer
    field :publisher, :string
  end
end
