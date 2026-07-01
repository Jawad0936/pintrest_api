defmodule PinterestApiWeb.Schema.Types.PinTypes do
  use Absinthe.Schema.Notation
  alias PinterestApiWeb.Schema.Resolvers

  enum :pin_status do
    value(:pending, as: "pending")
    value(:completed, as: "completed")
  end

  object :pin do
    field :id, non_null(:id)
    field :description, non_null(:string)
    field :category, non_null(:string)
    field :status, non_null(:pin_status)
    field :deadline, :datetime
    field :completed_at, :datetime
    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)

    field :logs, non_null(list_of(non_null(:log))) do
      resolve(&Resolvers.LogResolver.logs_for_pin/3)
    end

    field :user, non_null(:user) do
      resolve(&Resolvers.UserResolver.user_for_pin/3)
    end
  end

  object :pin_edge do
    field :node, non_null(:pin)
    field :cursor, non_null(:cursor)
  end

  object :page_info do
    field :has_next_page, non_null(:boolean)
    field :end_cursor, :cursor
  end

  object :pin_connection do
    field :edges, non_null(list_of(non_null(:pin_edge)))
    field :page_info, non_null(:page_info)
  end

  object :pin_payload do
    field :pin, :pin
    field :errors, list_of(non_null(:field_error))
  end

  object :delete_payload do
    field :success, non_null(:boolean)
    field :errors, list_of(non_null(:field_error))
  end

  input_object :create_pin_input do
    field :description, non_null(:string)
    field :category, non_null(:string)
    field :board_id, :id
    field :deadline, :datetime
  end

  input_object :update_pin_input do
    field :description, :string
    field :category, :string
    field :board_id, :id
    field :deadline, :datetime
  end
end
