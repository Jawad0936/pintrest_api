defmodule PinterestApiWeb.Schema do
  use Absinthe.Schema

  alias PinterestApiWeb.Schema.Resolvers.{UserResolver, PinResolver, BoardResolver, LogResolver}

  import_types(Absinthe.Type.Custom)
  import_types(PinterestApiWeb.Schema.Types.CustomTypes)
  import_types(PinterestApiWeb.Schema.Types.ErrorTypes)
  import_types(PinterestApiWeb.Schema.Types.UserTypes)
  import_types(PinterestApiWeb.Schema.Types.PinTypes)
  import_types(PinterestApiWeb.Schema.Types.LogTypes)

  query do
    field :me, :user do
      resolve(&UserResolver.me/3)
    end

    field :pins, non_null(:pin_connection) do
      arg(:status, :pin_status)
      arg(:category, :string)
      arg(:first, :integer)
      arg(:after, :cursor)
      resolve(&PinResolver.list_pins/3)
    end

    field :pin, :pin do
      arg(:id, non_null(:id))
      resolve(&PinResolver.get_pin/3)
    end

    field :boards, non_null(list_of(non_null(:board))) do
      resolve(&BoardResolver.list_boards/3)
    end

    field :board, :board do
      arg(:id, non_null(:id))
      resolve(&BoardResolver.get_board/3)
    end
  end

  mutation do
    field :create_pin, non_null(:pin_payload) do
      arg(:input, non_null(:create_pin_input))
      resolve(&PinResolver.create_pin/3)
    end

    field :update_pin, non_null(:pin_payload) do
      arg(:id, non_null(:id))
      arg(:input, non_null(:update_pin_input))
      resolve(&PinResolver.update_pin/3)
    end

    field :delete_pin, non_null(:delete_payload) do
      arg(:id, non_null(:id))
      resolve(&PinResolver.delete_pin/3)
    end

    field :complete_pin, non_null(:pin_payload) do
      arg(:id, non_null(:id))
      resolve(&PinResolver.complete_pin/3)
    end

    field :create_log, non_null(:log_payload) do
      arg(:pin_id, non_null(:id))
      arg(:description, non_null(:string))
      resolve(&LogResolver.create_log/3)
    end

    field :update_log, non_null(:log_payload) do
      arg(:id, non_null(:id))
      arg(:description, non_null(:string))
      resolve(&LogResolver.update_log/3)
    end

    field :delete_log, non_null(:delete_payload) do
      arg(:id, non_null(:id))
      resolve(&LogResolver.delete_log/3)
    end
  end
end
