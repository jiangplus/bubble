defmodule BubbleWeb.Router do
  use BubbleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug CORSPlug, [origin: "*"]
    plug :accepts, ["json"]
  end

  pipeline :event do
    plug CORSPlug, [origin: "*"]
    plug :accepts, ["event-stream"]
  end

  scope "/", BubbleWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", BubbleWeb do
    pipe_through :api

    get "/list_keys", PubsubController, :list_keys
    post "/publish", PubsubController, :publish
    post "/add_key", PubsubController, :add_key
    post "/remove_key", PubsubController, :remove_key
  end

  scope "/pubsub", BubbleWeb do
    pipe_through :event

    get "/", PubsubController, :subscribe
  end
end
