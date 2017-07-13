defmodule LoadResource do
  @moduledoc """
  The application module that ensures we have a connection to the repo.
  """

  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Application.get_env(:load_resource, :repo), []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LoadResource.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
