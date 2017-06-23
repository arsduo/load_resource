defmodule CommonplaceFeeds.LoadResource do
  import Plug.Conn
  import Ecto.Query

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

  def call(conn, %{check_auth: check_auth, id_key: id_key, model: model, handler: handler, resource_name: resource_name}) do
    id = conn.params[id_key]
    # user = Guardian.Plug.current_resource(conn)

    base_query = from row in model, where: row.id == ^(id)
    # query = if check_auth do
    #   from row in base_query, where: row.user_id == ^(user.id)
    # else
    #   base_query
    # end

    resource = CommonplaceFeeds.Repo.one(base_query)

    if resource do
      assign(conn, resource_name, resource)
    else
      handler.(conn, %{"id" => id})
      |> halt
    end
  end
end