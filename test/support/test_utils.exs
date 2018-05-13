# This is a script rather than a compiled file so that it can use ExUnit.Case, which requires
# ExUnit to be started first.
defmodule LoadResource.TestUtils do
  use ExUnit.Case, async: true
  use Plug.Test

  @doc """
  A helper for getting a connection with the params loaded.
  """
  def plug_with_fetched_params(params \\ nil) do
    :get
    |> conn("/", params)
    |> Plug.Conn.fetch_query_params
  end

  @doc """
  A helper for running a plug, modified from https://github.com/ueberauth/guardian/blob/master/test/test_helper.exs#L31.

  Calls the plug module's `init/1` function with no arguments and passes the results to `call/2` as
  the second argument.
  """
  def run_plug(conn, plug_module, initial_options) do
    options = apply(plug_module, :init, [initial_options])
    apply(plug_module, :call, [conn, options])
  end

  def assert_query_equality(query, expected_query) do
    # we need to compare these two queries without caring about the particular files that
    # triggered them
    # This is terrible.
    remove_files_from_query = fn(query) ->
      query = Map.from_struct(query)
      wheres = query[:wheres]
      cleansed_wheres = Enum.map(wheres, fn(clause) -> Map.drop(clause, [:file, :line]) end)
      Map.put(query, :wheres, cleansed_wheres)
    end

    assert remove_files_from_query.(query) == remove_files_from_query.(expected_query)
  end
end

