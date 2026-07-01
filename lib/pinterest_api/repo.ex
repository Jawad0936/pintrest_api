defmodule PinterestApi.Repo do
  use Ecto.Repo,
    otp_app: :pinterest_api,
    adapter: Ecto.Adapters.Postgres
end
