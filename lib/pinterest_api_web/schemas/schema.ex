defmodule PinterestApiWeb.Schema do
  use Absinthe.Schema

  import_types(Absinthe.Type.Custom)
  import_types(PinterestApiWeb.Schema.Types.CustomTypes)
  import_types(PinterestApiWeb.Schema.Types.ErrorTypes)
  import_types(PinterestApiWeb.Schema.Types.UserTypes)
  import_types(PinterestApiWeb.Schema.Types.PinTypes)
  import_types(PinterestApiWeb.Schema.Types.LogTypes)

  query do
    field :ping, :string do
      resolve(fn _, _ -> {:ok, "pong"} end)
    end
  end
end
