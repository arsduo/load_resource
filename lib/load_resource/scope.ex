defmodule LoadResource.Scope do
  @moduledoc """
  This module defines a scope that can be used in validating a resouce.

  A simple example: we have books and citations. When loading a citation, we want to validate that it belongs to a valid book -- that is, to add `citation.book_id = ${valid_book_id}` to our SQL query.

  Scopes contain two attributes:

  * `foreign_key`: the column on the resource to check
  * `accessor`: a function/1 that accepts `conn` and returns a value (see below)

  The value returned by `accessor` can be either:

  * a primitive (atom, string, number, or boolean), in which case it is used in the SQL query
  * a map or struct containing an `:id` key, in which case the id value is used

  Any other value will result in an `LoadResource.Scope.UnprocessableValueError` being raised.
  """

  @enforce_keys [:foreign_key, :accessor]
  defstruct [:foreign_key, :accessor]

  alias LoadResource.Scope

  @doc """
  A convenience method for creating scopes for earlier loaded resources.

  `Scope.from_atom(:book)` is equivalent to writing:

  ```
  %Scope{
    foreign_key: :book_id,
    accessor: fn(conn) -> conn.assigns[:book]
  }
  ```

  In pseudo-SQL, that scope turns into `where book_id = {conn.assigns[:book].id}`.

  (This assumes `conn.assigns[:book]` is an appropriate value, as it will be if it's a something previously loaded by `LoadResource.Plug`.)
  """
  def from_atom(scope_key) when is_atom(scope_key) do
    %Scope{
      foreign_key: :"#{scope_key}_id",
      accessor: fn(conn) -> conn.assigns[scope_key] end
    }
  end

  @doc """
  Run a scope on a given `conn` object and return the value for use by `LoadResource.QueryBuilder`.

  If needed, this method will transform the result of the `accessor` function into an appropriate value (for instance, from a map containing an `:id` key to the appropriate value).

  Given this scope and an `identify_source_book_id/1` function that returns either `"foo"` or `%{id: "foo"}`:

  ```
  scope = %Scope{foreign_key: :source_book_id, accessor: &identify_source_book_id/1}
  ```

  `Scope.evaluate(scope)` will return "foo".
  ```
  """
  def evaluate(%Scope{accessor: accessor}, conn) do
    process_scope_value(accessor.(conn))
  end

  defp process_scope_value(value) when is_atom(value), do: value
  defp process_scope_value(value) when is_bitstring(value), do: value
  defp process_scope_value(value) when is_number(value), do: value
  defp process_scope_value(value) when is_boolean(value), do: value
  defp process_scope_value(%{id: id}), do: id
  defp process_scope_value(value) do
    raise Scope.UnprocessableValueError, value
  end
end