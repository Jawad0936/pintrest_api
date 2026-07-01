defmodule PinterestApi.DataloaderSource do
  @moduledoc """
  Builds the Ecto-backed Dataloader source used by the Absinthe schema
  to batch-load associations and avoid N+1 queries.
  """

  alias PinterestApi.Repo

  def data do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  # Default: no custom filtering per association
  def query(queryable, _args), do: queryable
end
