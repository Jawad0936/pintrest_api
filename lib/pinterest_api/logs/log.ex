defmodule PinterestApi.Logs.Log do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "logs" do
    field :description, :string
    field :system, :boolean, default: false

    belongs_to :pin, PinterestApi.Pins.Pin

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [:description, :system, :pin_id])
    |> validate_required([:description, :pin_id])
    |> foreign_key_constraint(:pin_id)
  end
end
