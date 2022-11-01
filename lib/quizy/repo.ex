defmodule Quizy.Repo do
  use Ecto.Repo,
    otp_app: :quizy,
    adapter: Ecto.Adapters.Postgres

  def rename_bool_attrs(attrs, fields) when is_list(fields) do
    attrs
    |> Enum.filter(fn
      {field, value} -> field in fields
    end)
    |> Enum.map(fn {field, value} -> {"#{field}?", value} end)
    |> Map.new()
    |> Map.merge(attrs)
    |> Map.drop(fields)
  end
end
