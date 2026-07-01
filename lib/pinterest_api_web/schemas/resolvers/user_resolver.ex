defmodule PinterestApiWeb.Schema.Resolvers.UserResolver do
  alias PinterestApi.Accounts
  alias PinterestApi.Repo

  def me(_parent, _args, %{context: %{current_user: user}}), do: {:ok, user}
  def me(_parent, _args, _resolution), do: {:ok, nil}

  def user_for_pin(pin, _args, _resolution) do
    pin = Repo.preload(pin, :user)
    {:ok, pin.user}
  end

  def get_user(_parent, %{id: id}, _resolution) do
    case Accounts.get_user(id) do
      nil -> {:error, "User not found"}
      user -> {:ok, user}
    end
  end
end
