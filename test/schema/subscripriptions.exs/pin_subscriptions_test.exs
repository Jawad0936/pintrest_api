defmodule PinterestApiWeb.Schema.Subscriptions.PinSubscriptionsTest do
  use PinterestApiWeb.ChannelCase

  import PinterestApi.Factory

  alias PinterestApiWeb.{UserSocket, Endpoint}

  setup do
    user = insert_user()
    {:ok, socket} = Phoenix.ChannelTest.connect(UserSocket, %{}, %{})
    socket = Absinthe.Phoenix.Socket.put_options(socket, context: %{current_user: user})
    {:ok, socket: socket, user: user}
  end

  test "receives pinCreated event when a pin is created for that user", %{
    socket: socket,
    user: user
  } do
    ref =
      push_doc(socket, """
      subscription {
        pinCreated(userId: "#{user.id}") { id description status }
      }
      """)

    assert_reply(ref, :ok, %{subscriptionId: subscription_id})

    {:ok, pin} = PinterestApi.Pins.create_pin(%{
      description: "Realtime pin",
      category: "learning",
      user_id: user.id
    })

    Absinthe.Subscription.publish(Endpoint, pin, pin_created: user.id)

    assert_push("subscription:data", %{
      result: %{data: %{"pinCreated" => %{"description" => "Realtime pin"}}},
      subscriptionId: ^subscription_id
    })
  end

  defp push_doc(socket, query) do
    ref = Phoenix.ChannelTest.push(socket, "doc", %{"query" => query})
    ref
  end
end
