defmodule LoadResource.PlugTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Plug.Test

  import Ecto.Query
  import TestHelper

  alias LoadResource.Scope

  @default_opts [model: TestModel, handler: &TestErrorHandler.not_found/2]

  describe "init" do
    test "processes the options properly, processing the resource_name" do
      opts = LoadResource.Plug.init(@default_opts)
      assert opts == %{
        model: TestModel,
        resource_name: :test_model,
        handler: &TestErrorHandler.not_found/2
      }
    end

    test "it raises an error if model isn't provided" do
      assert_raise KeyError, fn ->
        LoadResource.Plug.init([])
      end
    end
  end

  describe "call with no result" do
    setup do
      TestRepo.enqueue_result(nil)
      id = 123
      conn = plug_with_fetched_params(%{"id" => id})
      {:ok, %{id: id, conn: run_plug(conn, LoadResource.Plug, @default_opts)}}
    end

    test "halts the chain", %{conn: conn} do
      assert conn.halted
    end

    test "it runs the conn through the error handler's not_found", %{conn: conn, id: id} do
      assert conn.resp_body == "not_found #{id}"
    end
  end

  describe "call with a result" do
    setup do
      model = %{"a" => "model", of: "something"}
      id = 123
      TestRepo.enqueue_result(model)
      conn = plug_with_fetched_params(%{"id" => id})
      {:ok, %{id: id, model: model, conn: run_plug(conn, LoadResource.Plug, @default_opts)}}
    end

    test "makes an appropriate query", %{id: id} do
      query = TestRepo.last_query
      expected_query = from row in TestModel, where: row.id == ^(id)
      assert_query_equality(query, expected_query)
    end

    test "assigns the result to the appropriate key", %{conn: conn, model: model} do
      assert conn.assigns[:test_model] == model
    end
  end

  describe "call with a different ID param" do
    setup do
      model = %{"a" => "model", of: "something"}
      id = 123
      TestRepo.enqueue_result(model)
      conn = plug_with_fetched_params(%{"resource_id" => id})
      {:ok, %{id: id, model: model, conn: run_plug(conn, LoadResource.Plug, @default_opts ++ [id_key: "resource_id"])}}
    end

    test "makes an appropriate query", %{id: id} do
      query = TestRepo.last_query
      # The query should still be the same, since we've fetched the ID just from a different param
      expected_query = from row in TestModel, where: row.id == ^(id)

      assert_query_equality(query, expected_query)
    end
  end

  describe "call with additional scopes" do
    setup do
      model = %{"a" => "model", of: "something"}
      id = 123
      book_id = "abc"
      book_type = "novel"
      TestRepo.enqueue_result(model)

      scope = :book
      second_scope = %Scope{column: :book_type, value: fn(conn) -> conn.params["book_type"] end}

      # Set up a connection with the right params that's already been procesesd with a previous
      # resource
      conn = %{"id" => id, "book_type" => book_type}
             |> plug_with_fetched_params
             |> Plug.Conn.assign(:book, %{id: book_id})

      {:ok, %{id: id, book_id: book_id, book_type: book_type, model: model, conn: run_plug(conn, LoadResource.Plug, @default_opts ++ [scopes: [scope, second_scope]])}}
    end

    test "it layers in additional scopes", %{id: id, book_id: book_id, book_type: book_type} do
      query = TestRepo.last_query
      expected_query = from row in TestModel,
                          where: ^[{:id, id}],
                          where: ^[{:book_id, book_id}],
                          where: ^[{:book_type, book_type}]

      assert_query_equality(query, expected_query)
    end
  end
end
