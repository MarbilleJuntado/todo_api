defmodule TodoApiWeb.InfoController do
  use TodoApiWeb, :controller

  def info(conn, _params) do
    vsn = Application.spec(:todo_api, :vsn)

    json(conn, %{version: List.to_string(vsn)})
  end
end
