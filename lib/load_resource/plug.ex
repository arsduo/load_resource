defmodule LoadResource.Plug do
  @moduledoc """
  This plug allows you to do some things.
  """

  import Plug.Conn

  alias LoadResource.Scope

  @repo Application.get_env(:load_resource, :repo)

  def init(default_options) do
    options = Enum.into(default_options, %{})

    # In order to allow us to load multiple resource for one controller, we need to have unique
    # names for the value that gets stored on conn. To do that, we generate the name of the
    # resource from the model name.
    # It's safe to use Macro.underscore here because we know the text only contains characters
    # valid for Elixir identifiers. (See https://hexdocs.pm/elixir/Macro.html#underscore/1.)
    model = Map.fetch!(options, :model)
    resource_name = String.to_atom(Macro.underscore(List.last(String.split(to_string(model), "."))))

    Map.put(options, :resource_name, resource_name)
  end

  def call(conn, %{model: model, handler: handler, resource_name: resource_name} = options) do
    id_key = options[:id_key] || "id"

    id_scope = %Scope{
      column: :id,
      value: fn(conn) -> conn.params[id_key] end
    }
    scopes = options[:scopes] || []

    query = LoadResource.QueryBuilder.build(model, conn, [id_scope] ++ scopes)

    resource = @repo.one(query)

    if resource do
      assign(conn, resource_name, resource)
    else
      conn
      |> handler.(id_scope.value.(conn))
      |> halt
    end
  end
end