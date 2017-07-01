defmodule LoadResource.Scope.UnprocessableValueError do
  @moduledoc """
  An error raised when `LoadResource.Scope.evaluate/2` encounters a result type it doesn't know how to process.
  """

  alias LoadResource.Scope.UnprocessableValueError

  defexception [:message, :value]

  @doc false
  def exception(value) do
    %UnprocessableValueError{
      message: "Unable to handle result of scope value. Expected atom | string | %{id: id} struct.",
      value: value
    }
  end
end
