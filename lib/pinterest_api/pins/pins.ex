defmodule PinterestApi.Pins do
  import Ecto.Query, warn: false
  alias PinterestApi.Repo
  alias PinterestApi.Pins.Pin

  @default_page_size 10
  @max_page_size 50

  def get_pin(id), do: Repo.get(Pin, id)
  def get_pin!(id), do: Repo.get!(Pin, id)

  def create_pin(attrs) do
    %Pin{}
    |> Pin.changeset(attrs)
    |> Repo.insert()
  end

  def update_pin(%Pin{} = pin, attrs) do
    pin
    |> Pin.changeset(attrs)
    |> Repo.update()
  end

  def delete_pin(%Pin{} = pin), do: Repo.delete(pin)

  def complete_pin(%Pin{} = pin) do
    pin
    |> Pin.complete_changeset()
    |> Repo.update()
  end

  @doc """
  Cursor-paginated pin listing.

  Options:
    :user_id  - required, scopes to the owning user
    :status   - optional filter ("pending" | "completed")
    :category - optional filter
    :first    - page size (default 10, capped at 50)
    :after    - opaque cursor string from a previous page's endCursor

  Returns %{edges: [%{node: pin, cursor: cursor}], page_info: %{has_next_page: bool, end_cursor: cursor | nil}}
  """
  def paginate_pins(opts) do
    user_id = Keyword.fetch!(opts, :user_id)
    first = opts |> Keyword.get(:first, @default_page_size) |> clamp_page_size()

    query =
      Pin
      |> where([p], p.user_id == ^user_id)
      |> maybe_filter_status(Keyword.get(opts, :status))
      |> maybe_filter_category(Keyword.get(opts, :category))
      |> maybe_apply_cursor(Keyword.get(opts, :after))
      |> order_by([p], desc: p.inserted_at)
      # fetch one extra row to know if there's a next page
      |> limit(^(first + 1))

    results = Repo.all(query)

    {page, has_next_page} =
      if length(results) > first do
        {Enum.take(results, first), true}
      else
        {results, false}
      end

    edges =
      Enum.map(page, fn pin ->
        %{node: pin, cursor: encode_cursor(pin.inserted_at)}
      end)

    end_cursor = edges |> List.last() |> then(&(&1 && &1.cursor))

    %{
      edges: edges,
      page_info: %{
        has_next_page: has_next_page,
        end_cursor: end_cursor
      }
    }
  end

  defp maybe_filter_status(query, nil), do: query
  defp maybe_filter_status(query, status), do: where(query, [p], p.status == ^status)

  defp maybe_filter_category(query, nil), do: query
  defp maybe_filter_category(query, category), do: where(query, [p], p.category == ^category)

  defp maybe_apply_cursor(query, nil), do: query

  defp maybe_apply_cursor(query, cursor) when is_binary(cursor) do
    case decode_cursor(cursor) do
      {:ok, timestamp} -> where(query, [p], p.inserted_at < ^timestamp)
      :error -> query
    end
  end

  defp clamp_page_size(n) when n > @max_page_size, do: @max_page_size
  defp clamp_page_size(n) when n < 1, do: @default_page_size
  defp clamp_page_size(n), do: n

  def encode_cursor(%DateTime{} = dt) do
    dt
    |> DateTime.to_iso8601()
    |> Base.url_encode64()
  end

  def decode_cursor(cursor) do
    with {:ok, decoded} <- Base.url_decode64(cursor),
         {:ok, dt, _} <- DateTime.from_iso8601(decoded) do
      {:ok, dt}
    else
      _ -> :error
    end
  end
end
