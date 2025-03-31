defmodule TodoApiWeb.TaskController do
  use TodoApiWeb, :controller

  alias TodoApi.Tasks
  alias TodoApi.Tasks.Task

  action_fallback TodoApiWeb.FallbackController

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    tasks = Tasks.list_tasks(user.id)
    render(conn, :index, tasks: tasks)
  end

  def create(conn, %{"task" => task_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %Task{} = task} <- Tasks.create_task(user.id, task_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/tasks/#{task}")
      |> render(:show, task: task)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    case Tasks.get_task(user.id, id) do
      %Task{} = task ->
        render(conn, :show, task: task)

      _ ->
        {:error, :not_found}
    end
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    user = Guardian.Plug.current_resource(conn)

    with %Task{} = task <- Tasks.get_task(user.id, id),
         {:ok, %Task{} = task} <- Tasks.update_task(task, task_params) do
      render(conn, :show, task: task)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with %Task{} = task <- Tasks.get_task(user.id, id),
         {:ok, %Task{}} <- Tasks.delete_task(task) do
      send_resp(conn, :no_content, "")
    end
  end
end
