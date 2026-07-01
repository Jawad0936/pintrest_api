defmodule PinterestApiWeb.Schema.Resolvers.UserResolver do
  alias PinterestApi.Accounts
  alias PinterestApi.Repo
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  def me(_parent, _args, %{context: %{current_user: user}}), do: {:ok, user}
  def me(_parent, _args, _resolution), do: {:ok, nil}

  def user_for_pin(pin, _args, %{context: %{loader: loader}}) do
    loader
    |> Dataloader.load(:db, Accounts.User, id: pin.user_id)
    |> on_load(fn loader ->
      {:ok, Dataloader.get(loader, :db, Accounts.User, id: pin.user_id)}
    end)
  end

  def get_user(_parent, %{id: id}, _resolution) do
    case Accounts.get_user(id) do
      nil -> {:error, "User not found"}
      user -> {:ok, user}
    end
  end
end
