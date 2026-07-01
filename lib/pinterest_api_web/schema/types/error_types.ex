defmodule PinterestApiWeb.Schema.Types.ErrorTypes do
  use Absinthe.Schema.Notation

  object :field_error do
    field :field, non_null(:string)
    field :message, non_null(:string)
    field :code, :string
  end
end
