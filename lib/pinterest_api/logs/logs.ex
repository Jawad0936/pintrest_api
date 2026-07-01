defmodule PinterestApi.Logs do
  import Ecto.Query, warn: false
  alias PinterestApi.Repo
  alias PinterestApi.Logs.Log

  def list_logs_for_pin(pin_id) do
    Log
    |> where([l], l.pin_id == ^pin_id)
    |> order_by([l], asc: l.inserted_at)
    |> Repo.all()
  end

  def get_log(id), do: Repo.get(Log, id)
  def get_log!(id), do: Repo.get!(Log, id)

  def create_log(attrs) do
    %Log{}
    |> Log.changeset(attrs)
    |> Repo.insert()
  end

  def create_system_log(pin_id, description) do
    create_log(%{pin_id: pin_id, description: description, system: true})
  end

  def update_log(%Log{} = log, attrs) do
    log
    |> Log.changeset(attrs)
    |> Repo.update()
  end

  def delete_log(%Log{} = log), do: Repo.delete(log)
end
