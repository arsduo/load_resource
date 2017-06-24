defmodule LoadResource.PlugTest do
 @moduledoc false
  use ExUnit.Case, async: true
  use Plug.Test

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

  describe "call" do
    setup do
      {:ok, %{conn: plug_with_fetched_params(%{"id" => 123})}}
    end

    test "rejects the request if it can't be found", %{conn: conn} do
      TestRepo.enqueue_result(nil)
      conn = run_plug(conn, LoadResource.Plug, @default_opts)
      IO.puts inspect(conn)
      assert nil == conn.assigns[:test_model]
    end
  end
end
