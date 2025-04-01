defmodule TodoApiWeb.Policies.Task do
  alias TodoApi.Tasks
  alias TodoApi.Tasks.Task
  alias TodoApi.Accounts.User

  use Dictator.Policies.EctoSchema, for: Task

  def load_resource(%{"id" => id}), do: Tasks.get_task(id)

  def load_resource(_), do: :no_load

  # User can view, update, delete, and reorder their own tasks
  def can?(%User{id: id}, action, %{resource: %Task{user_id: id}})
      when action in [:show, :update, :delete, :reorder],
      do: true

  # Users can't do anything else
  # on things they don't own
  def can?(_, _, _), do: false
end
