defmodule TestErrorHandler do
  @moduledoc """
  A test error handler.
  """

  def not_found(conn, id) do
    conn
    |> Plug.Conn.send_resp(404, "not_found #{id}")
  end
end
