defmodule TestModel do
  use Ecto.Schema

  schema "books" do
    field :title, :string
    field :isbn, :string
  end
end
