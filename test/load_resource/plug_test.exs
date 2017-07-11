defmodule LoadResource.PlugTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Plug.Test

  import TestHelper

  alias LoadResource.Scope

  @default_opts [model: TestModel, handler: &TestErrorHandler.not_found/1]

  def create_model do
    on_exit "clean up models", fn() -> TestRepo.delete_all(TestModel) end
    {:ok, model} = TestRepo.insert(%TestModel{title: "Foo Bar", user_id: 123, publisher: "C00l B00ks"})
    model
  end

  describe "init" do
    test "processes the options properly, processing the resource_name" do
      opts = LoadResource.Plug.init(@default_opts)
      assert opts == %{
        model: TestModel,
        resource_name: :test_model,
        handler: &TestErrorHandler.not_found/1,
        required: true
      }
    end

    test "it raises an error if model isn't provided" do
      assert_raise KeyError, fn ->
        LoadResource.Plug.init([])
      end
    end
  end

  describe "call with no result and required: true (default)" do
    setup do
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

  describe "call with no result and required: false" do
    setup do
      conn = plug_with_fetched_params(%{"id" => 123})
      {:ok, %{conn: run_plug(conn, LoadResource.Plug, @default_opts ++ [required: false])}}
    end

    test "does not halt the chain", %{conn: conn} do
      refute conn.halted
    end

    test "does not render anything", %{conn: conn} do
      refute conn.resp_body
    end

    test "it does not assign anything", %{conn: conn} do
      refute conn.assigns[:test_model]
    end
  end

  describe "call with a result" do
    setup do
      model = create_model()
      conn = plug_with_fetched_params(%{"id" => model.id})
      {:ok, %{model: model, conn: run_plug(conn, LoadResource.Plug, @default_opts)}}
    end

    test "loads the book", %{conn: conn, model: model} do
      assert conn.assigns[:test_model] == model
    end
  end

  describe "call with a different ID param" do
    setup do
      model = create_model()
      conn = plug_with_fetched_params(%{"resource_id" => model.id})
      {:ok, %{model: model, conn: run_plug(conn, LoadResource.Plug, @default_opts ++ [id_key: "resource_id"])}}
    end

    test "makes an appropriate query", %{conn: conn, model: model} do
      assert conn.assigns[:test_model] == model
    end
  end

  describe "call with additional scopes that succeeds" do
    setup do
      model = create_model()
      scope = :user
      second_scope = %Scope{column: :publisher, value: fn(_conn) -> "C00l B00ks" end}

      # Set up a connection with the right params that's already been procesesd with a previous
      # resource
      conn = %{"id" => model.id}
             |> plug_with_fetched_params
             |> Plug.Conn.assign(:user, %{id: model.user_id})

      {:ok, %{model: model, conn: run_plug(conn, LoadResource.Plug, @default_opts ++ [scopes: [scope, second_scope]])}}
    end

    test "it works with scopes", %{model: model, conn: conn} do
      assert conn.assigns[:test_model] == model
    end
  end

  describe "call with a scope that fails" do
    setup do
      model = create_model()
      scope = :user
      second_scope = %Scope{column: :publisher, value: fn(_conn) -> "C00l B00ks" end}

      # Set up a connection with the right params that's already been procesesd with a previous
      # resource
      conn = %{"id" => model.id}
             |> plug_with_fetched_params
             |> Plug.Conn.assign(:user, %{id: 1})

      {:ok, %{model: model, conn: run_plug(conn, LoadResource.Plug, @default_opts ++ [scopes: [scope, second_scope]])}}
    end

    test "it fails to load the data", %{conn: conn} do
      refute conn.assigns[:test_model]
    end
  end
end
