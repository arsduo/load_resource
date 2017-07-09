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
  username: System.get_env("PG_USER"),
  password: System.get_env("PG_PASS"),
  database: System.get_env("PG_DB"),
  hostname: System.get_env("PG_HOST"),
  pool_size: 10
