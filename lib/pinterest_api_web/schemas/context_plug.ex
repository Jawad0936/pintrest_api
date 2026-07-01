defmodule PinterestApiWeb.Schema.ContextPlug do
  @behaviour Plug

  import Plug.Conn
  alias PinterestApi.Guardian

  def init(opts), do: opts

  def call(conn, _opts) do
    context =
      case get_req_header(conn, "authorization") do
        ["Bearer " <> token] -> build_context(token)
        _ -> %{}
      end

    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(token) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        case Guardian.resource_from_claims(claims) do
          {:ok, user} -> %{current_user: user}
          {:error, _} -> %{}
        end

      {:error, _} ->
        %{}
    end
  end
end
