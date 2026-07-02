defmodule PinterestApi.Factory do
  alias PinterestApi.Repo
  alias PinterestApi.Accounts.User
  alias PinterestApi.Boards.Board
  alias PinterestApi.Pins.Pin
  alias PinterestApi.Logs.Log

  def insert_user(attrs \\ %{}) do
    defaults = %{
      name: "Test User",
      email: "user#{System.unique_integer([:positive])}@example.com",
      password: "password123"
    }

    %User{}
    |> User.changeset(Map.merge(defaults, attrs))
    |> Repo.insert!()
  end

  def insert_board(attrs \\ %{}) do
    user = Map.get(attrs, :user) || insert_user()

    defaults = %{
      name: "Test Board",
      category: "learning",
      user_id: user.id
    }

    %Board{}
    |> Board.changeset(Map.merge(defaults, Map.delete(attrs, :user)))
    |> Repo.insert!()
  end

  def insert_pin(attrs \\ %{}) do
    user = Map.get(attrs, :user) || insert_user()

    defaults = %{
      description: "Test pin",
      category: "learning",
      user_id: user.id
    }

    %Pin{}
    |> Pin.changeset(Map.merge(defaults, Map.delete(attrs, :user)))
    |> Repo.insert!()
  end

  def insert_log(attrs \\ %{}) do
    pin = Map.get(attrs, :pin) || insert_pin()

    defaults = %{
      description: "Test log entry",
      pin_id: pin.id
    }

    %Log{}
    |> Log.changeset(Map.merge(defaults, Map.delete(attrs, :pin)))
    |> Repo.insert!()
  end
end
