defmodule TodoApiWeb.AuthController do
  use TodoApiWeb, :controller

  use ExUnit.Case, async: false

  alias TodoApi.Accounts
  alias TodoApi.Accounts.User

  action_fallback TodoApiWeb.FallbackController

  def register(conn, %{"username" => _, "password" => _} = params) do
    with {:ok, %User{} = user} <- Accounts.create_user(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  def login(conn, %{"username" => username, "password" => password}) do
    with {:ok, %User{} = user} <- Accounts.authenticate_user(username, password),
         {:ok, token, _claims} <- TodoApi.Guardian.encode_and_sign(user) do
      conn
      |> put_status(:ok)
      |> render(:user_token, user: user, token: token)
    end
  end
end
