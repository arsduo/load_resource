use Mix.Config

# SETTINGS FOR ALL USAGE (plug development + usage in other apps)
#
# Tell the plug which repo to use
config :load_resource, repo: TestRepo

# SETTINGS FOR PLUG DEVELOPMENT ONLY

# This configures the plug to have an Ecto repo so that we can run mix commands while developing (ecto.migrate,
# ecto.create, etc.). In a regular app, your main OTP app would handle this.
config :load_resource, ecto_repos: [TestRepo]

# These get picked up from Docker.
config :load_resource, TestRepo,
  adapter: Ecto.Adapters.Postgres,
  hostname: System.get_env("PG_HOST"),
  username: System.get_env("PG_USER"),
  password: System.get_env("PG_PASS"),
  database: "load_resource_db",
  pool_size: 10
