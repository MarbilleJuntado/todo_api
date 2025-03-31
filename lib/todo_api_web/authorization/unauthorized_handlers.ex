defmodule TodoApiWeb.Authorization.UnauthorizedHandlers do
  @moduledoc """
  Basic unauthorized handler.
  """
  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(_), do: :ok

  @impl Plug
  def call(conn, _) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, Jason.encode!(%{error: "Unauthorized"}))
    |> halt()
  end
end
