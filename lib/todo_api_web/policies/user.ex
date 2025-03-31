defmodule TodoApiWeb.Policies.User do
  alias TodoApi.Accounts.User

  use Dictator.Policies.EctoSchema, for: User

  # User can see and update themselves
  def can?(%User{id: id}, action, %{resource: %User{id: id}})
      when action in [:show, :update],
      do: true

  # Users can't do anything else
  # on things they don't own
  def can?(_, _, _), do: false
end
