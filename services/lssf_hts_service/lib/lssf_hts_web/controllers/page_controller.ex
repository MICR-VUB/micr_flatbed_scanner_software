defmodule LssfHtsWeb.PageController do
  use LssfHtsWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    redirect(conn, to: ~p"/jobs")
  end
end
