defmodule LoadResource.ScopeTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias LoadResource.Scope

  describe "from_atom" do
    test "raises an exception if given a value not an atom" do
      assert_raise FunctionClauseError, fn() -> Scope.from_atom("booK") end
    end

    test "builds a scope with the right foreign key" do
      scope = Scope.from_atom(:book)
      assert scope.foreign_key == :book_id
    end

    test "builds a scope with the right accessor" do
      book =  %{some: :value}
      conn = %{assigns: %{book: book}}

      scope = Scope.from_atom(:book)
      assert scope.accessor.(conn) == book
    end
  end

  describe "evaluate" do
    setup do
      {:ok, %{scope: Scope.from_atom(:book)}}
    end

    test "evaluates an atom result properly", %{scope: scope} do
      conn = %{assigns: %{book: :book}}
      assert Scope.evaluate(scope, conn) == :book
    end

    test "evaluates an string result properly", %{scope: scope} do
      conn = %{assigns: %{book: "book"}}
      assert Scope.evaluate(scope, conn) == "book"
    end

    test "evaluates an numerical result properly", %{scope: scope} do
      conn = %{assigns: %{book: 123.5}}
      assert Scope.evaluate(scope, conn) == 123.5
    end

    test "evaluates an boolean result properly", %{scope: scope} do
      conn = %{assigns: %{book: true}}
      assert Scope.evaluate(scope, conn) == true
    end

    test "evaluates a map with an :id key properly", %{scope: scope} do
      conn = %{assigns: %{book: %{id: 1234}}}
      assert Scope.evaluate(scope, conn) == 1234
    end

    test "raises an UnprocessableValueError for anything else", %{scope: scope} do
      conn = %{assigns: %{book: %{some: :value}}}
      assert_raise Scope.UnprocessableValueError, fn() -> Scope.evaluate(scope, conn) end
    end
  end
end
