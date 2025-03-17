defmodule PollAppWeb.Router do
  use PollAppWeb, :router


  #import PollAppWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PollAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", PollAppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:poll_app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PollAppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", PollAppWeb do
    pipe_through :browser

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{PollAppWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/log_in", UserLoginLive, :new
      live "/", UserLoginLive, :new
    end

    post "/users/log_in", UserSessionController, :create
    delete "/users/log_out", UserSessionController, :delete

    live_session :require_authenticated_user,
      on_mount: [{PollAppWeb.UserAuth, :ensure_authenticated}] do
      live "/polls", PollLive.Index, :index
      live "/polls/new", PollLive.Index, :new
      live "/polls/:id", PollLive.Show, :show
    end
  end

end
