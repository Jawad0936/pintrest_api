defmodule PinterestApiWeb.Schema.Types.UserTypes do
  use Absinthe.Schema.Notation
  alias PinterestApiWeb.Schema.Resolvers

  object :user do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :email, non_null(:string)
    field :avatar_url, :string
    field :inserted_at, non_null(:datetime)

    field :pins, non_null(list_of(non_null(:pin))) do
      resolve(&Resolvers.PinResolver.pins_for_user/3)
    end

    field :boards, non_null(list_of(non_null(:board))) do
      resolve(&Resolvers.BoardResolver.boards_for_user/3)
    end
  end

  object :board do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :category, non_null(:string)

    field :pins, non_null(list_of(non_null(:pin))) do
      resolve(&Resolvers.PinResolver.pins_for_board/3)
    end

    field :pin_count, non_null(:integer) do
      resolve(&Resolvers.BoardResolver.pin_count/3)
    end
  end
end
