defmodule PinterestApiWeb.Schema do
  use Absinthe.Schema

  import_types(Absinthe.Type.Custom)
  import_types(PinterestApiWeb.Schema.Types.CustomTypes)

  query do
    field :ping, :string do
      resolve(fn _, _ -> {:ok, "pong"} end)
    end
  end
end
