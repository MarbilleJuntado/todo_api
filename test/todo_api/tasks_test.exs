defmodule TodoApi.TasksTest do
  use TodoApi.DataCase, async: true

  alias TodoApi.Tasks

  describe "tasks" do
    alias TodoApi.Tasks.Task

    import TodoApi.TasksFixtures
    import TodoApi.AccountsFixtures

    @invalid_attrs %{
      "description" => 1234,
      "title" => 5678
    }

    setup do
      user = user_fixture()
      user2 = user_fixture()
      task = task_fixture(user.id)
      task2 = task_fixture(user2.id)

      %{user: user, user2: user2, task: task, task2: task2}
    end

    test "list_tasks/1 returns all tasks", %{user: user, user2: user2, task: task, task2: task2} do
      assert Tasks.list_tasks(user.id) == [task]
      assert Tasks.list_tasks(user2.id) == [task2]
    end

    test "get_task/2 returns the task with given id", %{task: task} do
      assert Tasks.get_task(task.id) == task
    end

    test "create_task/1 with valid data creates a task", %{user: user} do
      valid_attrs = %{
        "description" => "some description",
        "title" => "some title"
      }

      assert {:ok, %Task{} = task} = Tasks.create_task(user.id, valid_attrs)
      assert task.position == Decimal.new("2.0")
      assert task.description == "some description"
      assert task.title == "some title"
    end

    test "create_task/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(user.id, @invalid_attrs)
    end

    test "update_task/2 with valid data updates the task", %{task: task} do
      update_attrs = %{
        "description" => "some updated description",
        "title" => "some updated title"
      }

      assert {:ok, %Task{} = task} = Tasks.update_task(task, update_attrs)
      assert task.description == "some updated description"
      assert task.title == "some updated title"
    end

    test "update_task/2 with invalid data returns error changeset", %{task: task} do
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task(task.id)
    end

    test "delete_task/1 deletes the task", %{task: task} do
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      refute Tasks.get_task(task.id)
    end
  end
end
