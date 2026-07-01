defmodule PinterestApiWeb.Schema.Resolvers.BoardResolver do
  alias PinterestApi.Boards

  def boards_for_user(user, _args, _resolution) do
    {:ok, Boards.list_boards_for_user(user.id)}
  end

  def pin_count(board, _args, _resolution) do
    {:ok, Boards.pin_count(board)}
  end

  def list_boards(_parent, _args, %{context: %{current_user: user}}) do
    {:ok, Boards.list_boards_for_user(user.id)}
  end

  def list_boards(_parent, _args, _resolution) do
    {:error, "Not authenticated"}
  end

  def get_board(_parent, %{id: id}, %{context: %{current_user: user}}) do
    case Boards.get_board(id) do
      nil -> {:error, "Board not found"}
      board when board.user_id == user.id -> {:ok, board}
      _board -> {:error, "Not authorized"}
    end
  end

  def get_board(_parent, _args, _resolution), do: {:error, "Not authenticated"}
end
