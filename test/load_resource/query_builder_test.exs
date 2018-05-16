defmodule LoadResource.QueryBuilderTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias LoadResource.QueryBuilder
  alias LoadResource.Scope

  import Ecto.Query
  import TestHelper

  def scope_test(conn) do
    conn.params[:book_type]
  end

  describe "build" do
    test "will add an atom scope" do
      scope = :book
      conn = %{assigns: %{book: %{id: 1234}}}

      expected_query = from row in TestModel, where: ^[{:book_id, 1234}]
      assert_query_equality(QueryBuilder.build(TestModel, conn, [scope]), expected_query)
    end

    test "will support complex scopes" do
      scope = %Scope{column: :book_type, value: &LoadResource.QueryBuilderTest.scope_test/1}
      conn = %{params: %{book_type: "novel"}}

      expected_query = from row in TestModel, where: ^[{:book_type, "novel"}]
      assert_query_equality(QueryBuilder.build(TestModel, conn, [scope]), expected_query)
    end

    test "layers multiple queries together" do
      scope = :book
      second_scope = %Scope{column: :book_type, value: &LoadResource.QueryBuilderTest.scope_test/1}
      conn = %{assigns: %{book: %{id: 1234}}, params: %{book_type: "novel"}}

      expected_query = from row in TestModel, where: ^[{:book_id, 1234}], where: ^[{:book_type, "novel"}]
      assert_query_equality(QueryBuilder.build(TestModel, conn, [scope, second_scope]), expected_query)
    end
  end
end
