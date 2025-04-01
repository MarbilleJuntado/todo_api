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

    test "create_task/1 with valid data creates a task", %{user: user, task: task} do
      valid_attrs = %{
        "description" => "some description",
        "title" => "some title"
      }

      assert {:ok, %Task{} = new_task} = Tasks.create_task(user.id, valid_attrs)
      assert new_task.description == "some description"
      assert new_task.title == "some title"
      assert Decimal.compare(new_task.position, task.position) == :gt
    end

    test "create_task/1 with valid data adds a task to top of list", %{user: user, task: task} do
      valid_attrs = %{
        "description" => "some description",
        "title" => "some title",
        "top?" => true
      }

      assert {:ok, %Task{} = new_task} = Tasks.create_task(user.id, valid_attrs)
      assert [first_task_on_list | _] = Tasks.list_tasks(user.id)
      assert new_task == first_task_on_list
      assert Decimal.compare(new_task.position, task.position) == :lt
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
