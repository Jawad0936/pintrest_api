defmodule PinterestApiWeb.Schema.Middleware.Auth do
  @behaviour Absinthe.Middleware

  def call(resolution, _config) do
    case resolution.context do
      %{current_user: %PinterestApi.Accounts.User{}} ->
        resolution

      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "Not authenticated"})
    end
  end
end
