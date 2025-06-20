defmodule LssfHtsWeb.Router do
  use LssfHtsWeb, :router

  import LssfHtsWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LssfHtsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    # plug :fetch_current_path
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LssfHtsWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", LssfHtsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:lssf_hts, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LssfHtsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", LssfHtsWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{LssfHtsWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", LssfHtsWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :default, on_mount: [{LssfHtsWeb.UserAuth, :mount_current_user}] do
      live "/jobs", JobLive.Index, :index
      live "/jobs/new", JobLive.New, :new
      live "/jobs/:id/edit", JobLive.Edit, :edit
    end
    live "/devices", DeviceLive.Index, :index
    live "/devices/new", DeviceLive.Index, :new
    live "/devices/:id/edit", DeviceLive.Index, :edit

    live "/devices/:id", DeviceLive.Show, :show
    live "/devices/:id/show/edit", DeviceLive.Show, :edit

    # live "/schedule", ScheduleLive, :index
    # live "/history", HistoryLive, :index
    live_session :require_authenticated_user,
      on_mount: [{LssfHtsWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", LssfHtsWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{LssfHtsWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
