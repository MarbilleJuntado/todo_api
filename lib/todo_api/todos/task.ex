defmodule TodoApi.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :position, :decimal
    field :description, :string
    field :title, :string

    belongs_to(:user, TodoApi.Accounts.User)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :position, :user_id])
    |> validate_required([:title, :description, :position, :user_id])
  end

  def update_changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description])
  end
end
