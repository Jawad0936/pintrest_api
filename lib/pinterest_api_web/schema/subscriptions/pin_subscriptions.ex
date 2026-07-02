defmodule PinterestApiWeb.Schema.Subscriptions.PinSubscriptions do
  use Absinthe.Schema.Notation

  object :pin_subscriptions do
    field :pin_created, non_null(:pin) do
      arg(:user_id, non_null(:id))

      config(fn args, _resolution ->
        {:ok, topic: args.user_id}
      end)
    end

    field :pin_completed, non_null(:pin) do
      arg(:user_id, non_null(:id))

      config(fn args, _resolution ->
        {:ok, topic: args.user_id}
      end)
    end

    field :notification_received, non_null(:notification) do
      arg(:user_id, non_null(:id))

      config(fn args, _resolution ->
        {:ok, topic: args.user_id}
      end)
    end
  end

  object :notification do
    field :id, non_null(:id)
    field :message, non_null(:string)
    field :inserted_at, non_null(:datetime)
  end
end
