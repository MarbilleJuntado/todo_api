defmodule TodoApiWeb.AuthControllerTest do
  use TodoApiWeb.ConnCase

  import TodoApi.AccountsFixtures

  alias TodoApi.Accounts

  @create_attrs %{
    username: "some username",
    password: "some password"
  }
  @invalid_attrs %{username: 1234, password: 5678}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/register", @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      assert user = Accounts.get_user!(id)
      assert user.username == "some username"
      assert true == Argon2.verify_pass("some password", user.hashed_password)
    end

    test "renders error when username has already been taken", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/register", @create_attrs)
      assert json_response(conn, 201)["data"]

      conn = post(conn, ~p"/api/auth/register", @create_attrs)
      assert json_response(conn, 422)["errors"] != %{}
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
end
