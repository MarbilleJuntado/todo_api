defmodule TodoApiWeb.TaskController do
  use TodoApiWeb, :controller

  alias TodoApi.Tasks
  alias TodoApi.Tasks.Task

  action_fallback TodoApiWeb.FallbackController

  plug Dictator, only: [:show, :update, :delete, :reorder]

  def index(conn, _params) do
    user = conn.assigns.current_user
    tasks = Tasks.list_tasks(user.id)
    render(conn, :index, tasks: tasks)
  end

  def create(conn, %{"task" => task_params}) do
    user = conn.assigns.current_user

    with {:ok, %Task{} = task} <- Tasks.create_task(user.id, task_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/tasks/#{task}")
      |> render(:show, task: task)
    end
  end

  def show(conn, %{"id" => id}) do
    case Tasks.get_task(id) do
      %Task{} = task ->
        render(conn, :show, task: task)

      _ ->
        {:error, :not_found}
    end
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    with %Task{} = task <- Tasks.get_task(id),
         {:ok, %Task{} = task} <- Tasks.update_task(task, task_params) do
      render(conn, :show, task: task)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Task{} = task <- Tasks.get_task(id),
         {:ok, %Task{}} <- Tasks.delete_task(task) do
      send_resp(conn, :no_content, "")
    end
  end

  def reorder(conn, %{"id" => id} = params) do
    with %Task{} = task <- Tasks.get_task(id),
         {:ok, %Task{} = task} <- Tasks.reorder_task(task, params) do
      render(conn, :show, task: task)
    end
  end
end
