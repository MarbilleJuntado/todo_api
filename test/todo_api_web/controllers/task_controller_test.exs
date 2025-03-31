defmodule TodoApiWeb.TaskControllerTest do
  use TodoApiWeb.ConnCase
  use ExUnit.Case, async: true

  alias TodoApi.Accounts
  alias TodoApi.Tasks
  alias TodoApi.Tasks.Task

  @create_attrs %{
    description: "some description",
    title: "some title"
  }
  @update_attrs %{
    description: "some updated description",
    title: "some updated title"
  }
  @invalid_attrs %{description: 456, title: 789}

  setup %{conn: conn} do
    {:ok, user} = Accounts.create_user(%{"username" => "test", "password" => "1234"})
    {:ok, user2} = Accounts.create_user(%{"username" => "test2", "password" => "5678"})

    {:ok, task} =
      Tasks.create_task(user.id, %{
        "description" => "some description",
        "title" => "some title"
      })

    {:ok, task2} =
      Tasks.create_task(user2.id, %{
        "description" => "some description 2",
        "title" => "some title 2"
      })

    {:ok, token, _} = TodoApi.Guardian.encode_and_sign(user)

    auth_conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok, token2, _} = TodoApi.Guardian.encode_and_sign(user2)

    auth_conn2 =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token2}")

    unauth_conn = put_req_header(conn, "accept", "application/json")

    {:ok,
     conn: auth_conn,
     conn2: auth_conn2,
     unauth_conn: unauth_conn,
     user: user,
     user2: user2,
     task: task,
     task2: task2}
  end

  describe "index" do
    test "lists all tasks when user is authenticated and authorized", %{
      conn: conn,
      conn2: conn2,
      task: task,
      task2: task2
    } do
      conn = get(conn, ~p"/api/tasks")

      assert [%{"id" => id, "title" => title, "description" => description, "position" => _}] =
               json_response(conn, 200)["data"]

      assert id == task.id
      assert title == task.title
      assert description == task.description

      conn2 = get(conn2, ~p"/api/tasks")

      assert [%{"id" => id, "title" => title, "description" => description, "position" => _}] =
               json_response(conn2, 200)["data"]

      assert id == task2.id
      assert title == task2.title
      assert description == task2.description
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
               "position" => "2.0",
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
    test "renders task when user is authenticated and authorized", %{
      conn: conn,
      task: %Task{id: id} = task
    } do
      conn = get(conn, ~p"/api/tasks/#{task}")

      assert %{"id" => ^id} = json_response(conn, 200)["data"]
    end

    test "renders errors when task does not exist", %{conn: conn} do
      conn = get(conn, ~p"/api/tasks/#{Ecto.UUID.generate()}")
      assert json_response(conn, 401)
    end

    test "renders errors when user is not authenticated", %{unauth_conn: conn, task: task} do
      conn = get(conn, ~p"/api/tasks/#{task}", task: @update_attrs)
      assert json_response(conn, 401)
    end

    test "renders error when user is not authorized", %{conn: conn, task2: task2} do
      conn = get(conn, ~p"/api/tasks/#{task2}")

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

    test "renders errors when user is unauthorized", %{conn: conn, task2: task2} do
      conn = put(conn, ~p"/api/tasks/#{task2}", task: @update_attrs)
      assert json_response(conn, 401)
    end
  end

  describe "delete task" do
    test "deletes chosen task successfully when user is authenticated", %{conn: conn, task: task} do
      conn = delete(conn, ~p"/api/tasks/#{task}")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/tasks/#{task}")
      assert json_response(conn, 401)
    end

    test "renders errors when user is not authenticated", %{unauth_conn: conn, task: task} do
      conn = delete(conn, ~p"/api/tasks/#{task}")
      assert json_response(conn, 401)
    end

    test "renders errors when user is unauthorized", %{conn: conn, task2: task2} do
      conn = delete(conn, ~p"/api/tasks/#{task2}")
      assert json_response(conn, 401)
    end
  end
end
