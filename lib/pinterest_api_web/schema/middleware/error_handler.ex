defmodule PinterestApiWeb.Schema.Middleware.ErrorHandler do
  @behaviour Absinthe.Middleware

  def call(resolution, _config) do
    %{resolution | errors: Enum.map(resolution.errors, &format/1)}
  end

  defp format(%{message: _} = error), do: error

  defp format("Not authenticated") do
    %{message: "Not authenticated", extensions: %{code: "UNAUTHENTICATED"}}
  end

  defp format("Not authorized") do
    %{message: "Not authorized", extensions: %{code: "FORBIDDEN"}}
  end

  defp format(message) when is_binary(message) do
    %{message: message, extensions: %{code: "BAD_REQUEST"}}
  end

  defp format(other), do: other
end
