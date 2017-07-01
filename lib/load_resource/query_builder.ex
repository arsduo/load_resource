defmodule LoadResource.QueryBuilder do
  @moduledoc """
  Each time a connection comes in, we build up a query using a specified set of `LoadResource.Scope`s.

  Each scope representing a condition that needs to be fulfilled (looking up by ID, verifying a foreign key, checking another parameter, etc.); the QueryBuilder joins them all together into a single composite database query to be executed in the plug.
  """

  import Ecto.Query

  alias LoadResource.Scope

  @doc """
  Build an Ecto query for a model record by evaluating a set of scopes for a given connection.

  See `LoadResource.Scope` for more information on how scopes are constructed.

  Example:

  ```
  scope = %Scope{foreign_key: :source_book_id, accessor: &identify_source_book_id/1}
  QueryBuilder.build(Quote, conn, [scope])
  # => select * from quotes where source_book_id = ${identify_source_book_id(conn)}

  QueryBuilder.build(Quote, conn, [:book])
  # scopes can be built from atoms -- see the Scope documentation
  # => select * from quotes where book_id = ${conn.assigns[:book].id}
  ```

  Multiple scopes can be provided (and they don't have to all be foreign keys, either):
  ```
  scope = %Scope{foreign_key: :book_type, accessor: fn(conn) -> conn.params[:book_type] end}
  QueryBuilder.build(Quote, conn, [:book, scope])
  # => select * from quotes where book_id = ${conn.assigns[:book].id} and book_type = ${conn.params[:book_type]}
  """
  def build(model, conn, scopes) do
    query = from model
    Enum.reduce(scopes, query, fn(scope, query) ->
      add_clause(query, scope, conn)
    end)
  end

  defp add_clause(query, scope, conn) when is_atom(scope) do
    add_clause(query, Scope.from_atom(scope), conn)
  end

  defp add_clause(query, %Scope{} = scope, conn) do
    from query, where: ^[{scope.foreign_key, Scope.evaluate(scope, conn)}]
  end
end
