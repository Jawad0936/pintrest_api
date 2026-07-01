defmodule PinterestApiWeb.Schema.Resolvers.LogResolver do
  alias PinterestApi.Logs
  alias PinterestApi.Pins
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  def logs_for_pin(pin, _args, %{context: %{loader: loader}}) do
    loader
    |> Dataloader.load(:db, Logs.Log, pin_id: pin.id)
    |> on_load(fn loader ->
      {:ok, Dataloader.get(loader, :db, Logs.Log, pin_id: pin.id) || []}
    end)
  end

  def create_log(_parent, %{pin_id: pin_id, description: description}, %{
        context: %{current_user: user}
      }) do
    with %Pins.Pin{} = pin <- Pins.get_pin(pin_id),
         true <- pin.user_id == user.id,
         {:ok, log} <- Logs.create_log(%{pin_id: pin_id, description: description}) do
      {:ok, %{log: log, errors: nil}}
    else
      nil -> {:ok, %{log: nil, errors: [%{field: "pin_id", message: "Pin not found"}]}}
      false -> {:ok, %{log: nil, errors: [%{field: "pin_id", message: "Not authorized"}]}}
      {:error, changeset} -> {:ok, %{log: nil, errors: format_errors(changeset)}}
    end
  end

  def create_log(_parent, _args, _resolution), do: {:error, "Not authenticated"}

  def update_log(_parent, %{id: id, description: description}, %{
        context: %{current_user: user}
      }) do
    with %Logs.Log{} = log <- Logs.get_log(id) |> preload_pin(),
         true <- log.pin.user_id == user.id,
         {:ok, updated} <- Logs.update_log(log, %{description: description}) do
      {:ok, %{log: updated, errors: nil}}
    else
      nil -> {:ok, %{log: nil, errors: [%{field: "id", message: "Log not found"}]}}
      false -> {:ok, %{log: nil, errors: [%{field: "id", message: "Not authorized"}]}}
      {:error, changeset} -> {:ok, %{log: nil, errors: format_errors(changeset)}}
    end
  end

  def update_log(_parent, _args, _resolution), do: {:error, "Not authenticated"}

  def delete_log(_parent, %{id: id}, %{context: %{current_user: user}}) do
    with %Logs.Log{} = log <- Logs.get_log(id) |> preload_pin(),
         true <- log.pin.user_id == user.id,
         {:ok, _} <- Logs.delete_log(log) do
      {:ok, %{success: true, errors: nil}}
    else
      nil -> {:ok, %{success: false, errors: [%{field: "id", message: "Log not found"}]}}
      false -> {:ok, %{success: false, errors: [%{field: "id", message: "Not authorized"}]}}
      {:error, changeset} -> {:ok, %{success: false, errors: format_errors(changeset)}}
    end
  end

  def delete_log(_parent, _args, _resolution), do: {:error, "Not authenticated"}

  defp preload_pin(nil), do: nil
  defp preload_pin(log), do: PinterestApi.Repo.preload(log, :pin)

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
