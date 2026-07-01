defmodule PinterestApiWeb.Router do
  use PinterestApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug :accepts, ["json"]
    plug PinterestApiWeb.Schema.ContextPlug
  end

  scope "/api", PinterestApiWeb do
    pipe_through :api

    post "/register", AuthController, :register
    post "/login", AuthController, :login
  end

  scope "/api" do
    pipe_through :graphql

    forward "/graphql", Absinthe.Plug, schema: PinterestApiWeb.Schema
  end

  scope "/graphiql" do
    pipe_through :graphql

    forward "/", Absinthe.Plug.GraphiQL,
      schema: PinterestApiWeb.Schema,
      interface: :playground
  end
end
