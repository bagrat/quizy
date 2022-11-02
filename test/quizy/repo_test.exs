defmodule Quizy.RepoTest do
  use ExUnit.Case, async: true

  alias Quizy.Repo

  test "rename_bool_attrs/2 appends '?' to the supplied fields" do
    assert %{"field1" => "something", "bool_field_1?" => true, "bool_field_2?" => false} ==
             Repo.rename_bool_attrs(
               %{"field1" => "something", "bool_field_1" => true, "bool_field_2" => false},
               ["bool_field_1", "bool_field_2"]
             )
  end
end
