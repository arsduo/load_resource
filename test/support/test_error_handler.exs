defmodule TestErrorHandler do
  @moduledoc """
  A test error handler.
  """

  def not_found(conn, data) do
    conn
    |> Plug.Conn.put_private(:not_found, data)
  end
end
