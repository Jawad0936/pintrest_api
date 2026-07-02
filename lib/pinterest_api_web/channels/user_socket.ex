defmodule PinterestApiWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: PinterestApiWeb.Schema

  alias PinterestApi.Guardian

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        case Guardian.resource_from_claims(claims) do
          {:ok, user} ->
            socket =
              socket
              |> Absinthe.Phoenix.Socket.put_options(context: %{current_user: user})

            {:ok, socket}

          {:error, _} ->
            :error
        end

      {:error, _} ->
        :error
    end
  end

  # Allow anonymous connections too — public subscriptions don't need a token,
  # though every subscription we define currently requires a userId anyway.
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
