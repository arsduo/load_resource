use Mix.Config

config :load_resource, LoadResource.TestRepo,
  adapter: Ecto.Adapters.Postgres,
  database: "load_resource_test",
  hostname: System.get_env("PG_HOST") || "localhost",
  username: System.get_env("PG_USER") || "postgres",
  password: System.get_env("PG_PASS") || "postgres",
  pool: Ecto.Adapters.SQL.Sandbox

config :load_resource,
         repo: LoadResource.TestRepo
