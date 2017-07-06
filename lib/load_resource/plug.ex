defmodule LoadResource.Plug do
  @moduledoc """
  This plug allows you to specify resources that your app should load and (optionally) validate as part of a request.

  ## Examples

  Load a Book resource using the `id` param on the incoming request:

  ```
  plug LoadResource.Plug, [model: Book, not_found: &MyErrorHandler.not_found/1]
  ```

  Use the `book_id` param instead of `id` (useful when composing multiple resources):

  ```
  plug LoadResource.Plug, [model: Book, id_key: "book_id", not_found: &MyErrorHandler.not_found/1]
  ```

  Load a Quote that matches to a previously loaded Book:

  ```
  plug LoadResource.Plug, [model: Quote, scopes: [:book], not_found: &MyErrorHandler.not_found/1]
  ```

  (See `LoadResource.Scope` for more information on scopes.)

  ## Accepted Options

  * `model`: an Ecto model representing the resource you want to load (required)
  * `not_found`: a function/1 that gets called if the record can't be found and `required: true` (required)
  * `id_key`: what param in the incoming request represents the ID of the record (optional, default: "id")
  * `required`: whether to halt the plug pipeline and return an error response if the record can't be found (optional, default: true)
  * `scopes`: an list of atoms and/or `LoadResource.Scope` structs (optional, default: [])
  """

  import Plug.Conn

  alias LoadResource.Scope

  @repo Application.get_env(:load_resource, :repo)

  @doc """
  Initialize the plug with any options provided in the controller or pipeline, including calculating the resource_name (which key will written to in `conn.assigns`) from the model.
  """
  def init(default_options) do
    options = Enum.into(default_options, %{required: true})

    # In order to allow us to load multiple resource for one controller, we need to have unique
    # names for the value that gets stored on conn. To do that, we generate the name of the
    # resource from the model name.
    # It's safe to use Macro.underscore here because we know the text only contains characters
    # valid for Elixir identifiers. (See https://hexdocs.pm/elixir/Macro.html#underscore/1.)
    model = Map.fetch!(options, :model)
    resource_name = String.to_atom(Macro.underscore(List.last(String.split(to_string(model), "."))))

    Map.put(options, :resource_name, resource_name)
  end

  @doc """
  Load a resource for a given request based on the previously-provided options.
  """
  def call(conn, %{model: model, handler: handler, resource_name: resource_name} = options) do
    id_key = options[:id_key] || "id"

    id_scope = %Scope{
      column: :id,
      value: fn(conn) -> conn.params[id_key] end
    }
    scopes = options[:scopes] || []

    query = LoadResource.QueryBuilder.build(model, conn, [id_scope] ++ scopes)

    query
    |> @repo.one
    |> handle_resource(conn, options)
  end

  defp handle_resource(nil, conn, %{required: true, handler: handler}) do
    conn
    |> handler.()
    |> halt
  end

  defp handle_resource(nil, conn, _options) do
    conn
  end

  defp handle_resource(resource, conn, %{resource_name: resource_name}) do
    assign(conn, resource_name, resource)
  end
end