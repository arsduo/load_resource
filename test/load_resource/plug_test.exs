defmodule LoadResource.PlugTest do
 @moduledoc false
  use ExUnit.Case, async: true
  use Plug.Test

  alias LoadResource.TestModel

  test "processes the options properly" do
    opts = LoadResource.Plug.init(model: TestModel)
    assert opts == %{model: TestModel, resource_name: :test_model}
  end
end
