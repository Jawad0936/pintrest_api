defmodule PinterestApiWeb.SchemaCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto.Query
      import PinterestApi.Factory
      import PinterestApiWeb.SchemaCase

      alias PinterestApi.Repo

      use PinterestApiWeb.ConnCase
    end
  end

  setup tags do
    PinterestApi.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Runs a GraphQL document against the schema with an optional current_user in context.
  """
  def run_query(query, opts \\ []) do
    context =
      case Keyword.get(opts, :current_user) do
        nil -> %{}
        user -> %{current_user: user}
      end

    Absinthe.run(query, PinterestApiWeb.Schema,
      variables: Keyword.get(opts, :variables, %{}),
      context: build_context(context)
    )
  end

  defp build_context(base) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(:db, PinterestApi.DataloaderSource.data())

    Map.put(base, :loader, loader)
  end
end
