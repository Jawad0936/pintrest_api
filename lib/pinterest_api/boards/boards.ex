defmodule PinterestApi.Boards do
  import Ecto.Query, warn: false
  alias PinterestApi.Repo
  alias PinterestApi.Boards.Board

  def list_boards_for_user(user_id) do
    Board
    |> where([b], b.user_id == ^user_id)
    |> order_by([b], desc: b.inserted_at)
    |> Repo.all()
  end

  def get_board(id), do: Repo.get(Board, id)

  def get_board!(id), do: Repo.get!(Board, id)

  def create_board(attrs) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  def update_board(%Board{} = board, attrs) do
    board
    |> Board.changeset(attrs)
    |> Repo.update()
  end

  def delete_board(%Board{} = board), do: Repo.delete(board)

  def pin_count(%Board{id: board_id}) do
    PinterestApi.Pins.Pin
    |> where([p], p.board_id == ^board_id)
    |> Repo.aggregate(:count, :id)
  end
end
