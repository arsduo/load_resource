defmodule LoadResource.ScopeTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias LoadResource.QueryBuilder
  alias LoadResource.Scope

  import Ecto.Query
  import TestHelper

  describe "build" do
    test "will add an atom scope" do
      scope = :book
      conn = %{assigns: %{book: %{id: 1234}}}

      expected_query = from row in TestModel, where: ^[{:book_id, 1234}]
      assert_query_equality(QueryBuilder.build(TestModel, conn, [scope]), expected_query)
    end

    test "will layer multiple scopes" do
      scope = %Scope{foreign_key: :book_type, accessor: fn(conn) -> conn.params[:book_type] end}
      conn = %{params: %{book_type: "novel"}}

      expected_query = from row in TestModel, where: ^[{:book_type, "novel"}]
      assert_query_equality(QueryBuilder.build(TestModel, conn, [scope]), expected_query)
    end

    test "layers multiple queries together" do
      scope = :book
      second_scope = %Scope{foreign_key: :book_type, accessor: fn(conn) -> conn.params[:book_type] end}
      conn = %{assigns: %{book: %{id: 1234}}, params: %{book_type: "novel"}}

      expected_query = from row in TestModel, where: ^[{:book_id, 1234}], where: ^[{:book_type, "novel"}]
      assert_query_equality(QueryBuilder.build(TestModel, conn, [scope, second_scope]), expected_query)
    end
  end
end
