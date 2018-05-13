ExUnit.start()

# Include any test scripts from the support directory.
Enum.map File.ls!("test/support") ++ File.ls!("test/support/migrations"), fn(file) ->
  if Regex.match?(~r/\.exs$/, file) do
    Code.require_file("test/support/#{file}")
  end
end

adapter = TestRepo.config[:adapter]
_ = adapter.storage_down(TestRepo.config)
:ok = adapter.storage_up(TestRepo.config)


{:ok, _pid} = TestRepo.start_link

:ok = Ecto.Migrator.up(TestRepo, 0, TestMigration, log: false)
