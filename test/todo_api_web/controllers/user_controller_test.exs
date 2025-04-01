defmodule TodoApiWeb.UserControllerTest do
  use TodoApiWeb.ConnCase, async: true

  alias TodoApi.Accounts
  alias TodoApi.Accounts.User

  @update_attrs %{
    username: "some updated username",
    password: "some updated password"
  }
  @invalid_attrs %{username: 1234, password: 5678}

  setup %{conn: conn} do
    {:ok, user} = Accounts.create_user(%{"username" => "test", "password" => "1234"})
    {:ok, user2} = Accounts.create_user(%{"username" => "test2", "password" => "5678"})

    {:ok, token, _} = TodoApi.Guardian.encode_and_sign(user)

    auth_conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    unauth_conn = put_req_header(conn, "accept", "application/json")

    {:ok, conn: auth_conn, unauth_conn: unauth_conn, user: user, user2: user2}
  end

  describe "show user" do
    test "renders user when user is authenticated and authorized", %{
      conn: conn,
      user: %User{id: id} = user
    } do
      conn = get(conn, ~p"/api/users/#{user}")
      assert %{"id" => ^id} = json_response(conn, 200)["data"]
    end

    test "renders error when user does not exist", %{conn: conn} do
      conn = get(conn, ~p"/api/users/#{Ecto.UUID.generate()}")

      assert json_response(conn, 401)
    end

    test "renders errors when user is not authenticated", %{unauth_conn: conn, user: user} do
      conn = get(conn, ~p"/api/users/#{user}")

      assert json_response(conn, 401)
    end

    test "renders errors when current user is unauthorized", %{conn: conn, user2: user2} do
      conn = get(conn, ~p"/api/users/#{user2}")

      assert json_response(conn, 401)
    end
  end

  describe "update user" do
    test "renders user when data is valid and user is authenticated and authorized", %{
      conn: conn,
      user: %User{id: id} = user
    } do
      conn = put(conn, ~p"/api/users/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "username" => "some updated username"
             } = json_response(conn, 200)["data"]

      assert user = Accounts.get_user(id)
      assert user.username == "some updated username"
      assert true == Argon2.verify_pass("some updated password", user.hashed_password)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when user is not authenticated", %{unauth_conn: conn, user: user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @update_attrs)

      assert json_response(conn, 401)
    end

    test "renders errors when current user is unauthorized", %{conn: conn, user2: user2} do
      conn = put(conn, ~p"/api/users/#{user2}", user: @update_attrs)

      assert json_response(conn, 401)
    end
  end
end
