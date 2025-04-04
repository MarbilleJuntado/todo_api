defmodule TodoApiWeb.Router do
  use TodoApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: TodoApi.Guardian,
      error_handler: TodoApiWeb.Plug.AuthErrorHandler

    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
    plug TodoApiWeb.Plug.CurrentUser
  end

  scope "/api", TodoApiWeb do
    pipe_through :api

    get "/info", InfoController, :info

    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
  end

  scope "/api", TodoApiWeb do
    pipe_through [:api, :auth]

    resources "/users", UserController, only: [:show, :update]
    resources "/tasks", TaskController, except: [:new, :edit]
    post "/tasks/:id/reorder", TaskController, :reorder
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:todo_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: TodoApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
