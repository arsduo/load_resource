defmodule LoadResource.PlugTest do
 @moduledoc false
  use ExUnit.Case, async: true
  use Plug.Test

  import Ecto.Query
  import TestHelper

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
      TestRepo.enqueue_result(model)
      conn = plug_with_fetched_params(%{"id" => 123})
      {:ok, %{model: model, conn: run_plug(conn, LoadResource.Plug, @default_opts)}}
    end

    test "looks up the query appropriately", %{conn: conn} do
      query = TestRepo.last_query
      expected_query = from row in TestModel, where: row.id == ^(123)
      # we need to compare these two queries without caring about the particular files that
      # triggered them
      # This is terrible.
      remove_files_from_query = fn(query) ->
        query = Map.from_struct(query)
        wheres = query[:wheres]
        Map.put(query, :wheres, Enum.map(wheres, fn(clause) -> Map.drop(clause, [:file, :line]) end))
      end

      assert remove_files_from_query.(query) == remove_files_from_query.(expected_query)
    end

    test "assigns the result to the appropriate key", %{conn: conn, model: model} do
      assert conn.assigns[:test_model] == model
    end
  end
end
