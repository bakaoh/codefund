for app <- Application.spec(:code_fund, :applications) do
  Application.ensure_all_started(app)
end

Application.ensure_all_started(:ex_unit)
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(CodeFund.Repo, :manual)

