defmodule TodoApiWeb.UserControllerTest do
  use TodoApiWeb.ConnCase

  import TodoApi.AccountsFixtures

  alias TodoApi.Accounts
  alias TodoApi.Accounts.User

  @create_attrs %{
    username: "some username",
    password: "some password"
  }
  @update_attrs %{
    username: "some updated username",
    password: "some updated password"
  }
  @invalid_attrs %{username: 1234, password: 5678}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, ~p"/api/users")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "register user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/register", @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "username" => "some username"
             } = json_response(conn, 200)["data"]

      assert user = Accounts.get_user!(id)
      assert user.username == "some username"
      assert true == Argon2.verify_pass("some password", user.hashed_password)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/register", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "login user" do
    setup do
      user = user_fixture()

      %{user: user}
    end

    test "logs in successfully when credentials are valid", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/auth/login", %{username: user.username, password: "some password"})

      assert %{"id" => id, "username" => username, "token" => _token} = json_response(conn, 200)
      assert id == user.id
      assert username == user.username
    end

    test "login fails when credentials are invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/login", %{username: "foo", password: "foo"})
      assert json_response(conn, 404)
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "username" => "some updated username"
             } = json_response(conn, 200)["data"]

      assert user = Accounts.get_user!(id)
      assert user.username == "some updated username"
      assert true == Argon2.verify_pass("some updated password", user.hashed_password)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/api/users/#{user}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/users/#{user}")
      end
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
