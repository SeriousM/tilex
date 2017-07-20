defmodule Tilex.Router do
  use Tilex.Web, :router

  @auth_controller Application.get_env(:tilex, :auth_controller)
  @cors_origin     Application.get_env(:tilex, :cors_origin)

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Tilex.Plug.BasicAuth
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    if @cors_origin do
      plug(CORSPlug, origin: @cors_origin)
    end

    plug :accepts, ["json"]
  end

  scope "/api", Tilex do
    pipe_through [:api]
  end

  scope "/", Tilex do
    pipe_through [:browser, :browser_auth]

    get "/rss", FeedController, :index
    get "/admin", @auth_controller, :index
    delete "/auth/logout", AuthController, :delete
    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
    post "/auth/:provider/callback", AuthController, :callback

    get "/statistics", StatsController, :index

    get "/sitemap.xml", SitemapController, :index
    get "/random", PostController, :random
    get "/:name", ChannelController, :show
    get "/authors/:name", DeveloperController, :show
    get "/profile/edit", DeveloperController, :edit
    put "/profile/edit", DeveloperController, :update

    get "/", PostController, :index
    resources "/posts", PostController, param: "titled_slug"
    post "/posts/:slug/like.json", PostController, :like
    post "/posts/:slug/unlike.json", PostController, :unlike
  end
end
