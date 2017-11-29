defmodule TrainWeb.Router do
  use TrainWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TrainWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/command", PageController, :command
    get "/faster", PageController, :faster
    get "/slower", PageController, :slower
  end

  # Other scopes may use custom stacks.
  # scope "/api", TrainWeb do
  #   pipe_through :api
  # end
end
