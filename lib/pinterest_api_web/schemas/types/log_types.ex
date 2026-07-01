defmodule PinterestApiWeb.Schema.Types.LogTypes do
  use Absinthe.Schema.Notation

  object :log do
    field :id, non_null(:id)
    field :description, non_null(:string)
    field :system, non_null(:boolean)
    field :inserted_at, non_null(:datetime)
  end

  object :log_payload do
    field :log, :log
    field :errors, list_of(non_null(:field_error))
  end
end
