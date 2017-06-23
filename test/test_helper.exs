defmodule LoadResource.TestHelper do
  @doc """
  Helper for running a plug, copied from https://github.com/ueberauth/guardian/blob/master/test/test_helper.exs#L31.

  Calls the plug module's `init/1` function with
  no arguments and passes the results to `call/2`
  as the second argument.
  """
  def run_plug(conn, plug_module) do
    opts = apply(plug_module, :init, [])
    apply(plug_module, :call, [conn, opts])
  end
end

defmodule LoadResource.TestRepo do
  use Ecto.Repo, otp_app: :load_resource
end

defmodule LoadResource.TestModel do
  use Ecto.Schema

  schema "books" do
    field :title, :string
    field :isbn, :string
  end
end

ExUnit.start()
