defmodule TodoApiWeb.TaskControllerTest do
  use TodoApiWeb.ConnCase

  alias TodoApi.Accounts
  alias TodoApi.Tasks
  alias TodoApi.Tasks.Task

  @create_attrs %{
    position: "120.5",
    description: "some description",
    title: "some title"
  }
  @update_attrs %{
    position: "456.7",
    description: "some updated description",
    title: "some updated title"
  }
  @invalid_attrs %{position: nil, description: nil, title: nil}

  setup %{conn: conn} do
    {:ok, user} = Accounts.create_user(%{"username" => "test", "password" => "1234"})

    {:ok, task} =
      Tasks.create_task(%{
        "user_id" => user.id,
        "description" => "some description",
        "position" => "120.5",
        "title" => "some title"
      })

    {:ok, token, _} = TodoApi.Guardian.encode_and_sign(user)

    auth_conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    unauth_conn = put_req_header(conn, "accept", "application/json")

    {:ok, conn: auth_conn, unauth_conn: unauth_conn, user: user, task: task}
  end

  describe "index" do
    test "lists all tasks when user is authenticated", %{conn: conn, task: task} do
      conn = get(conn, ~p"/api/tasks")

      assert [%{"id" => id, "title" => title, "description" => description, "position" => _}] =
               json_response(conn, 200)["data"]

      assert id == task.id
      assert title == task.title
      assert description == task.description
    end

    test "lists all tasks fails when user is not authenticated", %{unauth_conn: conn} do
      conn = get(conn, ~p"/api/tasks")
      assert json_response(conn, 401)
    end
  end

  describe "create task" do
    test "renders task when data is valid and user is authenticated", %{conn: conn} do
      conn = post(conn, ~p"/api/tasks", task: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/tasks/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "position" => "120.5",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/tasks", task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when user is not authenticated", %{unauth_conn: conn} do
      conn = post(conn, ~p"/api/tasks", task: @create_attrs)
      assert json_response(conn, 401)
    end
  end

  describe "show task" do
    test "renders task when user is authenticated", %{conn: conn, task: %Task{id: id} = task} do
      conn = get(conn, ~p"/api/tasks/#{task}")

      assert %{"id" => ^id} = json_response(conn, 200)["data"]
    end

    test "renders errors when task does not exist", %{conn: conn} do
      conn = get(conn, ~p"/api/tasks/#{Ecto.UUID.generate()}")
      assert json_response(conn, 404)
    end

    test "renders errors when user is not authenticated", %{unauth_conn: conn, task: task} do
      conn = get(conn, ~p"/api/tasks/#{task}", task: @update_attrs)
      assert json_response(conn, 401)
    end
  end

  describe "update task" do
    test "renders task when data is valid and user is authenticated", %{
      conn: conn,
      task: %Task{id: id} = task
    } do
      conn = put(conn, ~p"/api/tasks/#{task}", task: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/tasks/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "position" => "456.7",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, task: task} do
      conn = put(conn, ~p"/api/tasks/#{task}", task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when user is not authenticated", %{unauth_conn: conn, task: task} do
      conn = put(conn, ~p"/api/tasks/#{task}", task: @update_attrs)
      assert json_response(conn, 401)
    end
  end

  describe "delete task" do
    test "deletes chosen task successfully when user is authenticated", %{conn: conn, task: task} do
      conn = delete(conn, ~p"/api/tasks/#{task}")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/tasks/#{task}")
      assert json_response(conn, 404)
    end

    test "renders errors when user is not authenticated", %{unauth_conn: conn, task: task} do
      conn = delete(conn, ~p"/api/tasks/#{task}")
      assert json_response(conn, 401)
    end
  end
end
