defmodule PinterestApiWeb.Schema.Resolvers.PinResolver do
  alias PinterestApi.Pins
  alias PinterestApi.Repo
  import Ecto.Query
  import Absinthe.Resolution.Helpers, only: [on_load: 2]


 def pins_for_user(user, _args, %{context: %{loader: loader}}) do
  loader
  |> Dataloader.load(:db, {:many, Pins.Pin}, user_id: user.id)
  |> on_load(fn loader ->
    {:ok, Dataloader.get(loader, :db, {:many, Pins.Pin}, user_id: user.id)}
  end)
end

def pins_for_board(board, _args, %{context: %{loader: loader}}) do
  loader
  |> Dataloader.load(:db, {:many, Pins.Pin}, board_id: board.id)
  |> on_load(fn loader ->
    {:ok, Dataloader.get(loader, :db, {:many, Pins.Pin}, board_id: board.id)}
  end)
end

  def list_pins(_parent, args, %{context: %{current_user: user}}) do
    opts =
      [user_id: user.id]
      |> maybe_put(:status, Map.get(args, :status) && to_string(Map.get(args, :status)))
      |> maybe_put(:category, Map.get(args, :category))
      |> maybe_put(:first, Map.get(args, :first))
      |> maybe_put(:after, Map.get(args, :after))

    {:ok, Pins.paginate_pins(opts)}
  end

  def list_pins(_parent, _args, _resolution), do: {:error, "Not authenticated"}

  def get_pin(_parent, %{id: id}, %{context: %{current_user: user}}) do
    case Pins.get_pin(id) do
      nil -> {:error, "Pin not found"}
      pin when pin.user_id == user.id -> {:ok, pin}
      _pin -> {:error, "Not authorized"}
    end
  end

  def get_pin(_parent, _args, _resolution), do: {:error, "Not authenticated"}

  def create_pin(_parent, %{input: input}, %{context: %{current_user: user}}) do
    attrs = Map.put(input, :user_id, user.id)

    case Pins.create_pin(attrs) do
      {:ok, pin} -> {:ok, %{pin: pin, errors: nil}}
      {:error, changeset} -> {:ok, %{pin: nil, errors: format_errors(changeset)}}
    end
  end

  def create_pin(_parent, _args, _resolution), do: {:error, "Not authenticated"}

  def update_pin(_parent, %{id: id, input: input}, %{context: %{current_user: user}}) do
    with %Pins.Pin{} = pin <- Pins.get_pin(id),
         true <- pin.user_id == user.id,
         {:ok, updated} <- Pins.update_pin(pin, input) do
      {:ok, %{pin: updated, errors: nil}}
    else
      nil -> {:ok, %{pin: nil, errors: [%{field: "id", message: "Pin not found"}]}}
      false -> {:ok, %{pin: nil, errors: [%{field: "id", message: "Not authorized"}]}}
      {:error, changeset} -> {:ok, %{pin: nil, errors: format_errors(changeset)}}
    end
  end

  def update_pin(_parent, _args, _resolution), do: {:error, "Not authenticated"}

  def delete_pin(_parent, %{id: id}, %{context: %{current_user: user}}) do
    with %Pins.Pin{} = pin <- Pins.get_pin(id),
         true <- pin.user_id == user.id,
         {:ok, _} <- Pins.delete_pin(pin) do
      {:ok, %{success: true, errors: nil}}
    else
      nil -> {:ok, %{success: false, errors: [%{field: "id", message: "Pin not found"}]}}
      false -> {:ok, %{success: false, errors: [%{field: "id", message: "Not authorized"}]}}
      {:error, changeset} -> {:ok, %{success: false, errors: format_errors(changeset)}}
    end
  end

  def delete_pin(_parent, _args, _resolution), do: {:error, "Not authenticated"}

  def complete_pin(_parent, %{id: id}, %{context: %{current_user: user}}) do
    with %Pins.Pin{} = pin <- Pins.get_pin(id),
         true <- pin.user_id == user.id,
         {:ok, completed} <- Pins.complete_pin(pin) do
      {:ok, %{pin: completed, errors: nil}}
    else
      nil -> {:ok, %{pin: nil, errors: [%{field: "id", message: "Pin not found"}]}}
      false -> {:ok, %{pin: nil, errors: [%{field: "id", message: "Not authorized"}]}}
      {:error, changeset} -> {:ok, %{pin: nil, errors: format_errors(changeset)}}
    end
  end

  def complete_pin(_parent, _args, _resolution), do: {:error, "Not authenticated"}

  defp maybe_put(opts, _key, nil), do: opts
  defp maybe_put(opts, key, value), do: Keyword.put(opts, key, value)

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.flat_map(fn {field, messages} ->
      Enum.map(messages, fn message ->
        %{field: to_string(field), message: message}
      end)
    end)
  end
end
