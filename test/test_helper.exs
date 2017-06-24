# Include any test files from the support directory.
Enum.map File.ls!("test/support"), fn(file) ->
  if Regex.match?(~r/\.exs$/, file) do
    Code.require_file("test/support/#{file}")
  end
end

defmodule TestHelper do
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
end

ExUnit.start()
