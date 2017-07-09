use Mix.Config

# TestRepo isn't compiled with the main code in the package, so in order to make the module
# available at configuration time, we explicitly load it.
# See
#  * https://stackoverflow.com/questions/30652439/importing-test-code-in-elixir-unit-test
#  * https://hexdocs.pm/elixir/Code.html
Code.require_file("test/support/test_repo.exs")

config :load_resource, repo: TestRepo
