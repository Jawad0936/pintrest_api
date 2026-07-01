defmodule PinterestApiWeb.Schema.Types.CustomTypes do
  use Absinthe.Schema.Notation

  @desc "An opaque cursor used for paginating through connections"
  scalar :cursor, name: "Cursor" do
    serialize(&encode/1)
    parse(&decode/1)
  end

  defp encode(cursor) when is_binary(cursor), do: cursor
  defp encode(_), do: nil

  defp decode(%Absinthe.Blueprint.Input.String{value: value}) do
    {:ok, value}
  end

  defp decode(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp decode(_), do: :error
end
